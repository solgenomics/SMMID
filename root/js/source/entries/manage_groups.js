function display_groups(){

  $.ajax({
    url: '/rest/groups/list_groups',
    error: function(r){
      alert("Sorry, an error occurred: "+r.responseText);
    },
    success: function(r){
      if (r.error){
        alert(r.error);
        location.href= "/";
      }
      $('#groups_list').DataTable({
        // 'ajax': 'rest/groups/list_groups',
        'paging': false,
        'searching': true,
        'info': false,
        columns: [
          {title: "Group Name"},
          {title: "Remove Group", width:"20%"}
        ],
        data: r.data
      });
      $('#select_group_users').html(r.html);
    }
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
  }else{
    $('#display_group_users_table').DataTable({
      'ajax': '/rest/groups/list_group_users/'+group_id,
      'paging': false,
      'searching': true,
      'info': false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Remove", width: "10%"}
      ],
    });
  }
}

function initialize_new_group_modal(){

  $('#users_to_add_to_new_group').DataTable({
    'paging': false,
    'searching': true,
    'info' : false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Remove", width: "10%"}
    ],
    data: []
  });

  $('#select_users_for_new_group').DataTable({
    'ajax': '/rest/groups/list_users/new',
    'paging': false,
    'searching': true,
    'info' : false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Add", width: "10%"}
    ],
  });
}

function initialize_add_users_to_group_modal(){
  $('#users_to_add_to_existing_group').DataTable({
    'paging': false,
    'searching': true,
    'info' : false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Remove", width: "10%"}
    ],
    data: []
  });

  $('#select_users_for_existing_group').DataTable({
    'ajax': '/rest/groups/list_users/existing',
    'paging': false,
    'searching': true,
    'info' : false,
    columns: [
      {title: "User"},
      {title: "Email"},
      {title: "Organization"},
      {title: "Add", width: "10%"}
    ],
  });
}

//Note that row will correspond to dbuser_id, the only thing that can reliably id the exact user to be pushed up or down
//Also note that there are some confusing array indeces in this function. JavaScript is SUPER annoying about wrapping arrays
//in objects, so the extra array indeces are there to make sure the desired data is getting to where it needs to be.
//Final Note: Attempting to change the data being sent on the perl side may break this badly.
function push_array_entry(dbuser_id, direction, table1, table2){

  var row;
  var users_to_add = $('#'+table1).DataTable().data().toArray();
  var users_to_select_from = $('#'+table2).DataTable().data().toArray();
  $('#'+table1).DataTable().destroy();
  $('#'+table2).DataTable().destroy();

  if (direction == "up"){
    row = splice_row_from_id(dbuser_id, users_to_select_from);
    row[0][3] = '<button id="select_user_'+dbuser_id+'" type="button" class="btn btn-danger" onclick="push_array_entry('+dbuser_id+',    \'down\' , \''+table1+'\' , \''+table2+'\' )  "  > \u2193 </button>';
    users_to_add.push(row[0]);

    $('#'+table1).DataTable({
      'paging': false,
      'searching': true,
      'info' : false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Remove", width: "10%"}
      ],
      data:
        users_to_add
    });

    $('#'+table2).DataTable({
      'paging': false,
      'searching': true,
      'info' : false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Add", width: "10%"}
      ],
      data: users_to_select_from,
    });
  }
  if (direction == "down"){
    row = splice_row_from_id(dbuser_id, users_to_add);
    row[0][3] = '<button id="select_user_'+dbuser_id+'" type="button" class="btn btn-primary" onclick="push_array_entry('+dbuser_id+', \'up\' , \''+table1+'\' , \''+table2+'\' );" >\u2191</button>';
    users_to_select_from.push(row[0]);

    $('#'+table1).DataTable({
      'paging': false,
      'searching': true,
      'info' : false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Remove", width: "10%"}
      ],
      data: users_to_add
    });

    $('#'+table2).DataTable({
      'paging': false,
      'searching': true,
      'info' : false,
      columns: [
        {title: "User"},
        {title: "Email"},
        {title: "Organization"},
        {title: "Add", width: "10%"}
      ],
      data: users_to_select_from
    });
  }
}


function splice_row_from_id(dbuser_id, targetArray){
  for (var i=0; i<targetArray.length; i++){
    if (targetArray[i][4] == dbuser_id){
      return targetArray.splice(i, 1);
    }
  }
}

function enable_add_users(valid_team){
  if (valid_team != 0){
    $('#add_users_to_group_button').prop("disabled", false);
  } else {$('#add_users_to_group_button').prop("disabled", true);}
}
