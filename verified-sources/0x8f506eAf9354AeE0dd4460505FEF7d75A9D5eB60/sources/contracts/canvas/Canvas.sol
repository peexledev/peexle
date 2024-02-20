// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../lib/Ownable.sol";
import "./ICanvas.sol";
import "./CanvasBounds.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

library BytesReverse {
    function reverse(uint32 input) internal pure returns (uint32 v) {
        v = input;

        // swap bytes
        v = ((v & 0xFF00FF00) >> 8) | ((v & 0x00FF00FF) << 8);

        // swap 2-byte long pairs
        v = (v >> 16) | (v << 16);
    }

    function reverse(uint16 input) internal pure returns (uint16 v) {
        v = input;

        // swap bytes
        v = (v >> 8) | (v << 8);
    }
}

contract Canvas is ICanvas, CanvasBounds, Ownable {
    using BytesReverse for uint32;
    uint32 constant pixelSize = 1;
    bytes constant colors =
        hex"FFFFFFFF000000FF000000FF00FFFFCBC0FF00A5FF800080FFFF000000008080802A2AA52B8F37DB7093EBCE8713458B";
    uint256[chunksCountX * chunksCountY] _chunks;

    function getChunk(
        uint8 x,
        uint8 y
    ) external view inBounds(x, y) returns (uint256) {
        return _chunks[chunkIndex(x, y)];
    }

    function setChunk(uint8 x, uint8 y, uint256 chunkData) external onlyOwner {
        _chunks[chunkIndex(x, y)] = chunkData;
    }

    function setChunkByIndex(
        uint16 chunkIndex_,
        uint256 chunkData
    ) external onlyOwner {
        _chunks[chunkIndex_] = chunkData;
    }

    function getChunks()
        external
        view
        returns (uint256[chunksCountX * chunksCountY] memory)
    {
        return _chunks;
    }

    function color(uint8 index) private pure returns (bytes3 res) {
        bytes memory table = colors;
        assembly {
            res := mload(add(add(table, 32), mul(3, index)))
        }
    }

    function add(
        bytes memory b,
        uint32 index,
        bytes memory data
    ) internal pure returns (uint32) {
        uint256 len = data.length;
        uint32 n = index;
        for (uint32 i = 0; i < len; ++i) {
            b[index + i] = data[i];
            unchecked {
                ++n;
            }
        }
        return n;
    }

    function addBitmapColor(
        bytes memory b,
        uint32 index,
        bytes3 data
    ) internal pure returns (uint32) {
        uint32 n = index;
        unchecked {
            for (uint32 i = 0; i < 3; ++i) {
                b[index + i] = data[i];
                ++n;
            }
        }
        return n;
    }

    function getBitmap() external view returns (string memory) {
        uint32 pixelSizeX = chunksCountX * chunkPixelSize * pixelSize;
        uint32 pixelSizeY = chunksCountY * chunkPixelSize * pixelSize;
        uint32 headerSize = 54;
        uint32 pixelCount = pixelSizeX * pixelSizeY;
        uint32 al = pixelSizeX % 4;
        uint32 dataSize = pixelCount * 3 + pixelSizeY * al;
        uint32 size = headerSize + dataSize;

        bytes memory b = new bytes(size);
        uint32 i;
        i = add(b, i, hex"424D");
        i = add(b, i, abi.encodePacked(size.reverse()));
        i = add(b, i, hex"000000003600000028000000");
        i = add(b, i, abi.encodePacked(pixelSizeX.reverse()));
        i = add(b, i, abi.encodePacked(pixelSizeY.reverse()));
        i = add(b, i, hex"0100180000000000");
        i = add(b, i, abi.encodePacked(dataSize.reverse()));
        i = add(b, i, hex"00000000000000000000000000000000");

        uint256[chunksCountX * chunksCountY] memory chunks = _chunks;
        unchecked {
            for (uint32 y = 0; y < pixelSizeY; ++y) {
                for (uint32 x = 0; x < pixelSizeX; ++x) {
                    uint256 chunkIndex = ((y / pixelSize) / chunkPixelSize) *
                        chunksCountY +
                        ((x / pixelSize) / chunkPixelSize);
                    uint256 chunk = chunks[chunkIndex];
                    uint256 indexInChunk = ((y / pixelSize) % chunkPixelSize) *
                        chunkPixelSize +
                        ((x / pixelSize) % chunkPixelSize);
                    uint8 data = uint8((chunk >> (indexInChunk * 4)) & 0x0f);
                    i = addBitmapColor(b, i, color(data));
                }
                for (uint32 j = 0; j < al; ++j) b = bytes.concat(b, hex"00");
            }
        }
        return Base64.encode(b);
    }

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
