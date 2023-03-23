// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;


contract Login {

    struct User {
        bytes32 passwordHash;
        bool registered;
    }

    mapping(string => User) public users;

    function register(string memory _email, string memory _password) public payable {
        require(bytes(_email).length > 0, "Email is required");
        require(bytes(_password).length > 0, "Password is required");
        require(!users[_email].registered, "User already exists");

        bytes32 passwordHash = keccak256(bytes(_password));
        users[_email] = User(passwordHash, true);
    }

    function login(string memory _email, string memory _password) public view returns(bool) {
        require(bytes(_email).length > 0, "Email is required");
        require(bytes(_password).length > 0, "Password is required");

        bytes32 passwordHash = keccak256(bytes(_password));
        User storage user = users[_email];

        if (user.registered && user.passwordHash == passwordHash) {
            return true;
        } else {
            return false;
        }
    }
}