
// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol


// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/game/IGame.sol


pragma solidity ^0.8.23;

interface IGame {
    function isStarted() external view returns (bool);

    function gameEndTime() external view returns (uint256);

    function isGameEnd() external view returns (bool);

    function isWriteEnable() external view returns (bool);

    function isAuction() external view returns (bool);

    function isAuctionEnd() external view returns (bool);

    function isNftClaimed() external view returns (bool);
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/nft/IMintableNft.sol


pragma solidity ^0.8.23;

interface IMintableNft {
    function transfer(address to) external;

    function isTransferred() external view returns (bool);
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/canvas/ICanvas.sol


pragma solidity ^0.8.23;

uint16 constant chunksCountX = 24;
uint16 constant chunksCountY = 24;
uint8 constant chunkPixelSize = 1;

interface ICanvas {
    function getChunk(uint8 x, uint8 y) external view returns (uint256);

    function setChunk(uint8 x, uint8 y, uint256 chunkData) external;

    function setChunkByIndex(uint16 chunkIndex, uint256 chunkData) external;

    function getChunks()
        external
        view
        returns (uint256[chunksCountX * chunksCountY] memory);

    function getBitmap() external view returns (string memory);
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/canvas/CanvasBounds.sol


pragma solidity ^0.8.23;


abstract contract CanvasBounds {
    modifier inBounds(uint8 x, uint8 y) {
        require(x < chunksCountX, "position x out of bounds");
        require(y < chunksCountY, "position y out of bounds");
        _;
    }

    function getChunksCount() external pure returns (uint16 x, uint16 y) {
        return (chunksCountX, chunksCountY);
    }

    function chunkIndex(
        uint8 x,
        uint8 y
    ) public pure inBounds(x, y) returns (uint16) {
        return chunksCountX * y + x;
    }
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/lib/Ownable.sol


pragma solidity ^0.8.23;

contract Ownable {
    address _owner;

    event RenounceOwnership();

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "only owner");
        _;
    }

    function owner() external view virtual returns (address) {
        return _owner;
    }

    function ownerRenounce() public onlyOwner {
        _owner = address(0);
        emit RenounceOwnership();
    }

    function transferOwnership(address newOwner) external onlyOwner {
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

// File: verified-sources/0xa99142657a223d1f3834326bcfaf7b938d9841fb/sources/contracts/game/Game.sol


pragma solidity ^0.8.23;








struct ChunkData {
    address owner;
    uint256 price;
}
struct ChunkWriteDto {
    uint8 x;
    uint8 y;
    uint256 data;
}

abstract contract GameInternal is
    IGame,
    CanvasBounds,
    Ownable,
    ReentrancyGuard
{
    ICanvas immutable _canvas;
    address immutable dev;
    IERC20 public token;
    uint256 constant _tokenDecimals = 9;
    uint256 public constant startChunkWritePrice = 1 * (10 ** _tokenDecimals);
    uint256 public chunkOverridePricePercent = 10; // percent to to price to override chunk

    uint256 constant startGameTimer = 86400;
    uint256 public chunkWriteAddsGameSeconds = 60;
    uint256 public chunksWritenCount;
    uint256 _gameEndTime;
    ChunkData[chunksCountX * chunksCountY] _chunks;
    mapping(address => uint16) _ownersShare;

    constructor(address canvasAddress) {
        _canvas = ICanvas(canvasAddress);
        dev = msg.sender;
    }

    modifier writeEnable() {
        require(isWriteEnable(), "game not started");
        _;
    }

    function start() external onlyOwner {
        _gameEndTime = block.timestamp + startGameTimer;
    }

    function isStarted() external view returns (bool) {
        return _gameEndTime != 0;
    }

    function gameEndTime() external view returns (uint256) {
        return _gameEndTime;
    }

    function isGameEnd() public view returns (bool) {
        return _gameEndTime > 0 && _gameEndTime <= block.timestamp;
    }

    function isWriteEnable() public view returns (bool) {
        return _gameEndTime > 0 && !isGameEnd();
    }

    receive() external payable {}

    function setToken(address tokenAddress) external onlyOwner {
        require(address(token) == address(0));
        token = IERC20(tokenAddress);
    }

    function canvas() external view returns (address) {
        return address(_canvas);
    }

    function writeChunks(ChunkWriteDto[] calldata input) external writeEnable {
        uint256 cost = _writeChunksPrice(input, msg.sender);
        token.transferFrom(msg.sender, address(this), cost);
        for (uint256 i = 0; i < input.length; ++i) {
            _writeChunk(input[i], msg.sender);
        }
    }

    function _writeChunk(ChunkWriteDto calldata input, address writer) private {
        uint16 index = chunkIndex(input.x, input.y);
        ChunkData storage chunk = _chunks[index];

        address lastOwner = chunk.owner;
        if (lastOwner != address(0)) --_ownersShare[lastOwner];
        else ++chunksWritenCount;
        ++_ownersShare[msg.sender];

        chunk.price = _writeChunkPrice(chunk, writer);
        chunk.owner = msg.sender;
        _canvas.setChunkByIndex(index, input.data);

        _gameEndTime += chunkWriteAddsGameSeconds;
    }

    function getChunksOwners()
        external
        view
        returns (address[chunksCountX * chunksCountY] memory accs)
    {
        for (uint256 i = 0; i < chunksCountX * chunksCountY; ++i) {
            accs[i] = _chunks[i].owner;
        }
        return accs;
    }

    function _getChunk(
        uint8 x,
        uint8 y
    ) private view returns (ChunkData storage) {
        return _chunks[chunkIndex(x, y)];
    }

    function writeChunkPrice(uint8 x, uint8 y) private view returns (uint256) {
        return _writeChunkPrice(_getChunk(x, y), msg.sender);
    }

    function writeChunkPriceFor(
        uint8 x,
        uint8 y,
        address account
    ) private view returns (uint256) {
        return _writeChunkPrice(_getChunk(x, y), account);
    }

    function writeChunksPriceFor(
        address account
    ) private view returns (uint256[] memory) {
        uint256 size = chunksCountX * chunksCountY;
        uint256[] memory prices = new uint256[](size);
        for (uint256 i = 0; i < size; ++i) {
            _writeChunkPrice(_chunks[i], account);
        }
        return prices;
    }

    function writeChunksPrice(
        ChunkWriteDto[] calldata input
    ) external view returns (uint256) {
        return _writeChunksPrice(input, msg.sender);
    }

    function writeChunksPriceFor(
        ChunkWriteDto[] calldata input,
        address account
    ) external view returns (uint256) {
        return _writeChunksPrice(input, account);
    }

    function _writeChunkPrice(
        ChunkData memory data,
        address writer
    ) private view returns (uint256) {
        if (data.owner == writer) return 0;
        if (data.price == 0) return startChunkWritePrice;
        return data.price + (data.price * chunkOverridePricePercent) / 100;
    }

    function _writeChunksPrice(
        ChunkWriteDto[] calldata data,
        address writer
    ) private view returns (uint256) {
        uint256 cost;
        for (uint256 i = 0; i < data.length; ++i) {
            cost += _writeChunkPrice(_getChunk(data[i].x, data[i].y), writer);
        }
        return cost;
    }

    function getChunks()
        external
        view
        returns (ChunkData[chunksCountX * chunksCountY] memory)
    {
        return _chunks;
    }

    function getChunkOwner(
        uint8 x,
        uint8 y
    ) external view inBounds(x, y) returns (address) {
        return _chunks[chunkIndex(x, y)].owner;
    }

    function accountShare(address acc) external view returns (uint16) {
        return _ownersShare[acc];
    }
}

abstract contract Auction is GameInternal {
    IMintableNft public nft;
    uint256 constant auctionStartTimer = 86400;
    uint256 public constant auctionBidAddsTimer = 60;
    uint256 public constant auctionBidStepShare = 5;
    uint256 public constant auctionBidStepPrecesion = 100;
    address public bidAddress;
    uint256 public bidEther = 1e16 - 1; // starts 0.01 ether
    uint256 public auctionEndTime;
    uint256 public etherToClaimTotal;
    uint256 public tokenToClaimTotal;

    constructor(address canvasAddress) GameInternal(canvasAddress) {}

    modifier whenAuction() {
        require(isAuction(), "auction is not started");
        _;
    }

    function setNft(address nftAddress) external onlyOwner {
        require(address(nft) == address(0));
        nft = IMintableNft(nftAddress);
    }

    function isAuction() public view returns (bool) {
        if (!isGameEnd()) return false;
        return auctionEndTime == 0 || block.timestamp < auctionEndTime;
    }

    function isAuctionEnd() public view returns (bool) {
        return auctionEndTime > 0 && auctionEndTime <= block.timestamp;
    }

    function newBidEtherMin() public view returns (uint256) {
        return (bidEther * auctionBidStepShare) / auctionBidStepPrecesion;
    }

    function makeBid() external payable {
        require(isAuction(), "no auction time");
        require(msg.value > newBidEtherMin(), "bid is too low");
        if (bidAddress != address(0)) _sendEther(bidAddress, bidEther);
        bidAddress = msg.sender;
        bidEther = msg.value;
        if (auctionEndTime == 0)
            auctionEndTime = block.timestamp + auctionStartTimer;
        else auctionEndTime += auctionBidAddsTimer;
    }

    function _sendEther(address to, uint256 count) internal nonReentrant {
        if (count == 0) return;
        (bool sentFee, ) = payable(to).call{value: count}("");
        require(sentFee, "sent fee error: ether is not sent");
    }

    function claimNft() public {
        require(isAuctionEnd(), "auction still continue");
        require(!isNftClaimed(), "nft already claimed");
        nft.transfer(bidAddress);
        _sendEther(dev, bidEther / 5);
        etherToClaimTotal = address(this).balance;
        tokenToClaimTotal = token.balanceOf(address(this));
    }

    function isNftClaimed() public view returns (bool) {
        return nft.isTransferred();
    }
}

contract Game is Auction {
    mapping(address => bool) public isClaimed;

    constructor(address canvasAddress) Auction(canvasAddress) {}

    function claim() external {
        require(isAuctionEnd(), "auction still continue");
        if (!isNftClaimed()) claimNft();

        require(!isClaimed[msg.sender], "already claimed");
        isClaimed[msg.sender] = true;
        uint256 share = _ownersShare[msg.sender];
        require(share > 0, "account share is 0");
        _sendEther(msg.sender, (etherToClaimTotal * share) / chunksWritenCount);
        token.transfer(
            address(0),
            //msg.sender,
            (tokenToClaimTotal * share) / chunksWritenCount
        );
    }
}
