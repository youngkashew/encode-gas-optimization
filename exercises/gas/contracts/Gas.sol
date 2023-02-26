// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;

contract GasContract {
    uint256 public constant totalSupply = 10000; // cannot be updated
    mapping(address => uint256) private balances;
    address public contractOwner;
    mapping(address => Payment[]) public payments;
    mapping(address => uint256) public whitelist;
    address[5] public administrators;
    enum PaymentType {
        Unknown,
        BasicPayment,
        Refund,
        Dividend
    }

    struct Payment {
        PaymentType paymentType;
        uint256 amount;
    }

    event Transfer(address recipient, uint256 amount);

    constructor(address[] memory _admins, uint256) {
        balances[msg.sender] = totalSupply;
        for (uint8 i = 0; i < administrators.length;) {
            administrators[i] = _admins[i];
            unchecked {
                i++;
            }
        }
    }

    function checkForAdmin(address _user) public view returns (bool res) {
        for (uint8 i = 0; i < administrators.length;) {
            if (administrators[i] == _user) {
                res = true;
                break;
            }
            unchecked {
                i++;
            }
        }
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function getTradingMode() public pure returns (bool) {
        return true;
    }

    function getPayments(address _user) public view returns (Payment[] memory) {
        return payments[_user];
    }

    function transfer(
        address _recipient,
        uint256 _amount,
        string calldata
    ) public returns (bool) {
        balances[msg.sender] = balances[msg.sender] - _amount;
        balances[_recipient] += _amount;
        emit Transfer(_recipient, _amount);
        payments[msg.sender].push(Payment(PaymentType.BasicPayment, _amount));
        return true;
    }

    function updatePayment(
        address _user,
        uint8 idx,
        uint256 _amount,
        PaymentType _type
    ) public {
        require(checkForAdmin(msg.sender));

        Payment storage temp = payments[_user][idx-1];
        temp.paymentType = _type;
        temp.amount = _amount;
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        whitelist[_userAddrs] = _tier;
    }

    function whiteTransfer(
        address _recipient,
        uint256 _amount,
        uint64[3] calldata
    ) public {
        uint256 senderAmount = whitelist[msg.sender];
        uint256 senderBalance = balances[msg.sender];
        uint256 recipientBalance = balances[_recipient];
        assembly {
            senderBalance := add(sub(senderBalance, _amount), senderAmount)
            recipientBalance := sub(add(recipientBalance, _amount), senderAmount)
        }
        balances[msg.sender] = senderBalance;
        balances[_recipient] = recipientBalance;
    }
}
