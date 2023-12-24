// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
//["wang", "Alice", "Bob","Eve"]
contract VotingSystem {
    // 状态变量
    struct Candidate {
        string name;
        uint voteCount;
    }//结构体，包含候选人的名字和得票数。
    
    address public owner;//存储合约的创建者地址。
    mapping(address => bool) public voters;//映射，记录每个地址（选民）是否已注册并投票
    Candidate[] public candidates;//存储所有候选人
    bool public votingOpen = false;//表示投票是否开放

    // 事件
    event VoteReceived(address voter, string candidate);//收到投票时触发
    event VotingStatusChanged(bool newStatus);//投票状态改变

    // 创建候选人数组，设置合约创建者为拥有者，并将候选人添加到候选人数组中。
    constructor(string[] memory candidateNames) {
        owner = msg.sender;
        for(uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0 // 初始票数设置为0
            }));
        }
    }//

    // 只有合约拥有者可以调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    modifier isVotingOpen() { //查询投票系统是否开放
        require(votingOpen, "Voting is not open.");
        _;
    }

    //控制投票开放，保证在开放时才能投票
    function setVotingOpen(bool _open) public onlyOwner {
        votingOpen = _open;
        emit VotingStatusChanged(_open);
    }

    // 注册选民，每个地址都可以注册成为选民
    function registerVoter(address voter) public  {
        require(!voters[voter], "Voter is already registered.");
        voters[voter] = true;
    }

    // 查看候选人列表
 function CandidatesList() public view returns (string[] memory) {
    string[] memory names = new string[](candidates.length);
    for (uint i = 0; i < candidates.length; i++) {
        names[i] = candidates[i].name;
    }
    return names;
}



    // 投票，允许注册的选民为一个候选人投票，并防止重复投票
    function vote(uint candidateIndex) public isVotingOpen {
        //确保投票者是注册过但还没有投票的选民
        require(voters[msg.sender], "Only registered voters can vote,or You have already voted.");
        //确保选择的候选人的有效的
        require(candidateIndex < candidates.length, "Invalid candidate.");

        candidates[candidateIndex].voteCount += 1;
        voters[msg.sender] = false; // 防止重复投票

        emit VoteReceived(msg.sender, candidates[candidateIndex].name);
    }

     // 将候选人按票数由高到低进行排序
    function SortCandidates() public view  returns (Candidate[] memory) {
        Candidate[] memory sortedCandidates = new Candidate[](candidates.length);
        for (uint i = 0; i < candidates.length; i++) {
            sortedCandidates[i] = candidates[i];
        }

        // 使用冒泡排序
        bool swapped;
        do {
            swapped = false;
            for (uint i = 0; i < sortedCandidates.length - 1; i++) {
                if (sortedCandidates[i].voteCount < sortedCandidates[i + 1].voteCount) {
                    Candidate memory temp = sortedCandidates[i];
                    sortedCandidates[i] = sortedCandidates[i + 1];
                    sortedCandidates[i + 1] = temp;
                    swapped = true;
                }
            }
        } while (swapped);

        return sortedCandidates;
    }

}
