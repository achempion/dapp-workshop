var Web3 = require('web3');

window.client = new Web3(web3.currentProvider);
window.coinbase = ''


window.deploy = function () {
    var abi = [{ "constant": true, "inputs": [], "name": "getId", "outputs": [{ "name": "id_counter", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [], "name": "nextId", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "id", "outputs": [{ "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }]
    var data = '606060405260008055341561001357600080fd5b60de806100216000396000f30060606040526004361060525763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416635d1ca6318114605757806361b8ce8c146079578063af640d0f14608b575b600080fd5b3415606157600080fd5b6067609b565b60405190815260200160405180910390f35b3415608357600080fd5b608960a1565b005b3415609557600080fd5b606760ac565b60005490565b600080546001019055565b600054815600a165627a7a72305820414c782c7578801973a19b44d5cd532afbdd32a894e2d2dc955a3da88db33b230029'
    var contract = new window.client.eth.Contract(abi);

    contract.deploy({ data: data }).send({ from: window.coinbase });
}


var initContract = function () {
    var abi = [{ "constant": true, "inputs": [], "name": "getId", "outputs": [{ "name": "id_counter", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": false, "inputs": [], "name": "nextId", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "id", "outputs": [{ "name": "", "type": "uint256" }], "payable": false, "stateMutability": "view", "type": "function" }]
    var data = '606060405260008055341561001357600080fd5b60de806100216000396000f30060606040526004361060525763ffffffff7c01000000000000000000000000000000000000000000000000000000006000350416635d1ca6318114605757806361b8ce8c146079578063af640d0f14608b575b600080fd5b3415606157600080fd5b6067609b565b60405190815260200160405180910390f35b3415608357600080fd5b608960a1565b005b3415609557600080fd5b606760ac565b60005490565b600080546001019055565b600054815600a165627a7a72305820414c782c7578801973a19b44d5cd532afbdd32a894e2d2dc955a3da88db33b230029'

    return new window.client.eth.Contract(abi, '');
}

window.getId = function () {
    var contract = initContract();

    contract.methods.getId().call().then(function (data) {
        console.log(data);
        document.getElementById('res').innerHTML = data;
    });

}

window.nextId = function () {
    var contract = initContract();

    contract.methods.nextId().send({ from: window.coinbase, value: 0 });
}