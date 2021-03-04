function display_groups(){
  $('#groups_list').DataTable({
    'ajax': 'rest/groups/list_groups',
    'paging': false,
    'searching': true,
    'info': false,
    columns: [
      {title: "Group Name"},
      {title: "Remove Group", width:"20%"}
    ]
  });

}

function initialize_group_users(){
  $('#display_group_users_table').DataTable({
    'paging': false,
    'searching': true,
    'info': false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Remove", width: "10%"}
    ],
    data: [
    ]
  });
}

function display_group_users(group_id){

  if (group_id == 0){
    initialize_group_users();
  }

  if (group_id == 1){
    $('#display_group_users_table').DataTable({
      'paging': false,
      'searching': true,
      'info': false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Remove", width: "10%"}
      ],
      data: [
        ["Tyler", "email@cornell.edu", "BTI", "X"],
        ["Frank", "email@cornell.edu", "BTI", "X"]
      ]
    });
  }
  if (group_id == 2){
    $('#display_group_users_table').DataTable({
      'paging': false,
      'searching': true,
      'info': false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Remove", width: "10%"}
      ],
      data: [
        ["Marty", "email@cornell.edu", "BTI", "X"],
        ["Leila", "email@cornell.edu", "BTI", "X"]
      ]
    });
  }
}

function list_all_users(){
  $('#select_users_for_new_group').DataTable({
    'ajax': 'rest/groups/list_users',
    'paging': false,
    'searching': true,
    'info' : false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Add to new Group"}
    ],
  });
}
