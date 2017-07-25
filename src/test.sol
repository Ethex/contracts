pragma solidity ^0.4.12;


contract Test  {
  mapping (bytes32 => address) public myHash;

  event EventOne(bytes32 one);
  event EventTwo(bytes32 one,bytes32 two);

  function Test() {
  }
  function Zero() {

  }
  function One() { //gas:23384
      EventOne(sha256(msg.sender));
  }

  function Two() { //gas:24672
    EventOne(sha256(msg.sender),sha256(msg.sender,msg.value));
  }
  function Three() { //42733
    myHash[sha256(msg.sender)] = msg.sender;
  }
}
