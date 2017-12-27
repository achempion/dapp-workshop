pragma solidity ^0.4.16;

contract Fundraiser {

  //
  // Data structures
  //

  struct Project {
    uint id;
    address author;
    uint duration_in_days;
    uint eth_raise_amount;
    string title;
    string description;
    string repository_url;

    // meta info
    uint cancelled_at;
    uint finished_at;
    uint withdrawn_at;
    uint eth_raised_amount;
    uint created_at;
  }

  struct InvestedAmount {
    address investor;
    uint eth_invested;
    uint created_at;
    uint withdrawn_at;
  }

  uint   public id_counter = 0;
  uint[] public succeeded_project_ids;

  mapping (uint256 => Project) public projects;
  mapping (uint256 => InvestedAmount[]) public invested_amounts;
  mapping (address => uint[])  public invested_projects_by_address;

  //
  // Accessors
  //

  function getIdCounter() public view returns (uint counter) {
    return id_counter;
  }

  function getSucceededProjectIds() public view returns (uint[] project_ids) {
    return succeeded_project_ids;
  }

  function getInvestedProjectsByAddress(address investor) public view returns (uint[] project_ids) {
    return invested_projects_by_address[investor];
  }

  function getInvestedAmountLength(uint project_id) public view returns (uint length) {
    return invested_amounts[project_id].length;
  }
  function getInvestedAmount(uint project_id, uint index) public view returns (
    address investor,
    uint eth_invested,
    uint created_at,
    uint withdrawn_at
  ) {
    var elem = invested_amounts[project_id][index];

    return (
      elem.investor,
      elem.eth_invested,
      elem.created_at,
      elem.withdrawn_at
    );
  }

  function getProject(uint project_id) public view returns (
    uint id,
    address author,
    uint duration_in_days,
    uint eth_raise_amount,
    string title,
    string description,
    string repository_url,
    uint cancelled_at,
    uint finished_at,
    uint withdrawn_at,
    uint eth_raised_amount,
    // uint participant_counter,
    uint created_at
  ) {
    var project = projects[project_id];

    return (
      project.id,
      project.author,
      project.duration_in_days,
      project.eth_raise_amount,
      project.title,
      project.description,
      project.repository_url,
      project.cancelled_at,
      project.finished_at,
      project.withdrawn_at,
      project.eth_raised_amount,
    //   project.participant_counter,
      project.created_at
    );
  }


  //
  // Functions
  //

  // Create a funding program
  function placeProject(
    string title,
    string description,
    string repository_url,
    uint eth_raise_amount,
    uint duration_in_days
  ) public {
    // Allow maximum 100 days to fundraise
    if (duration_in_days > 100) revert();

    Project memory project;

    project.title            = title;
    project.description      = description;
    project.repository_url   = repository_url;
    project.eth_raise_amount = eth_raise_amount * 1 ether;

    project.created_at = block.timestamp;
    project.author     = msg.sender;

    // update counter and pick next empty id
    project.id = id_counter++;

    // Put the project into the storage
    projects[project.id] = project;
  }


  // Help project to succeed
  function participate(uint project_id) public payable {
    var project = projects[project_id];

    // check if the project exists
    if (project.id == 0) revert();
    // check if already cancelled or finished
    if (project.cancelled_at > 0 || project.finished_at > 0) revert();

    // append sent amount to the project
    project.eth_raised_amount += msg.value;

    // keep track of invested projects for supporter
    updateInvestedProjects(msg.sender, project_id);

    // keep track of invested amount by each supporter
    updateInvestedAmounts(msg.sender, project_id, msg.value);
  }


  function cancelFundingProgram(uint project_id) public {
    var project = projects[project_id];
    // check if the project exists
    if (project.id == 0) revert();
    // check if already cancelled or finished
    if (project.cancelled_at > 0 || project.finished_at > 0) revert();


    // cancel funding by author
    if (msg.sender == project.author) {
      project.cancelled_at = block.timestamp;
    } else {
      // cancel funding by deadline
      uint date_threshold = 1 days * project.duration_in_days + project.created_at;
      if (block.timestamp > date_threshold && project.eth_raised_amount < project.eth_raise_amount) {
        project.cancelled_at = block.timestamp;
      }
    }

    // in order to notify executor that won't succeed
    if (project.cancelled_at == 0) revert();
  }


  function finishFundingProgram(uint project_id) public {
    var project = projects[project_id];
    // check if the project exists
    if (project.id == 0) revert();
    // check if already cancelled or finished
    if (project.cancelled_at > 0 || project.finished_at > 0) revert();
    // check if goal is riched
    if (project.eth_raised_amount < project.eth_raise_amount) revert();


    // finish funding by author
    if (msg.sender == project.author) {
      project.finished_at = block.timestamp;
    }

    // in order to notify executor that won't succeed
    if (project.finished_at == 0) revert();
  }


  //
  // Widthdraws
  //

  function finishWithdraw(uint project_id) public {
    var project = projects[project_id];
    // check if the project exists
    if (project.id == 0) revert();
    // check if not finished
    if (project.finished_at == 0) revert();
    // check if already completed
    if (project.withdrawn_at > 0) revert();

    project.author.transfer(project.eth_raised_amount);
    project.withdrawn_at = block.timestamp;
    succeeded_project_ids.push(project_id);
  }

  function cancelParticipation(uint project_id) public {
    var project = projects[project_id];
    // check if the project exists
    if (project.id == 0) revert();
    // check if cancelled
    if (project.cancelled_at == 0) revert();

    bool is_already_tracking = false;
    for(uint i = 0; i < invested_amounts[project_id].length; i++)
    {
      // find the already existed struct for investor
      if (invested_amounts[project_id][i].investor == msg.sender) {
        is_already_tracking = true;
        InvestedAmount storage invested_amount = invested_amounts[project_id][i];

        // already taken
        if (invested_amount.withdrawn_at > 0) revert();

        // withdraw funds
        invested_amount.withdrawn_at = block.timestamp;
        invested_amount.investor.transfer(invested_amount.eth_invested);

        break;
      }
    }

    // in order to notify executor that won't succeed
    if (is_already_tracking == false) revert();
  }

  //
  // Internals
  //

  function updateInvestedProjects(address sender, uint project_id) internal {
    bool is_already_tracking = false;
    for(uint i = 0; i < invested_projects_by_address[sender].length; i++)
    {
      if (invested_projects_by_address[msg.sender][i] == project_id) {
        is_already_tracking = true;
        break;
      }
    }
    if (is_already_tracking == false) {
      invested_projects_by_address[sender].push(project_id);
    }
  }

  function updateInvestedAmounts(address sender, uint project_id, uint value) internal {
    bool is_already_tracking = false;
    for(uint i = 0; i < invested_amounts[project_id].length; i++)
    {
      // find the already existed struct for investor
      if (invested_amounts[project_id][i].investor == sender) {
        is_already_tracking = true;
        // increase amount of invested funds
        invested_amounts[project_id][i].eth_invested += value;
        break;
      }
    }
    // if there is a new investor for project
    if (is_already_tracking == false) {
      // define struct for new investor
      InvestedAmount memory invested_amount;
      invested_amount.investor = msg.sender;
      invested_amount.eth_invested = msg.value;
      invested_amount.created_at = block.timestamp;

      // append sturct to the project investors
      invested_amounts[project_id].push(invested_amount);
    }
  }
}
