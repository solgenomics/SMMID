function populate_profile_data(user_id){

  $.ajax({
    url: '/rest/user/'+user_id+'/profile',
    success: function(r){
      if(r.error){alert(r.error);}
      else{
        $('#user_name').html(r.data.full_name);
        $('#user_email').html(r.data.email_address);
        $('#user_type').html(r.data.user_role);
        $('#user_organization').html(r.data.organization);
        $('#user_username').html(r.data.username);

        $('#edit_first_name').val(r.data.first_name);
        $('#edit_last_name').val(r.data.last_name);
        $('#edit_email').val(r.data.email_address);
        $('#edit_organization').val(r.data.organization);
        $('#edit_username').val(r.data.username);
      }
    },
    error: function(r){
      alert("Sorry, an error occurred."+r.responseText);
    },
  });
}

function populate_authored_smids(user_id){

  $('#user_authored_smids').DataTable({
    'ajax': '/rest/user/'+user_id+'/authored_smids',
    'paging': false,
    'searching': false,
    'info': false,
    columns: [
      {title: "SMID ID"},
      {title: "Formula"},
      {title: "Molecular Weight"},
      {title: "Curation Status"}
    ]
  });

}

function populate_authored_experiments(user_id){

  $('#user_authored_experiments').DataTable({
    'ajax': '/rest/user/'+user_id+'/authored_experiments',
    'paging': false,
    'searching': false,
    'info': false,
    columns: [
      {title: "Experiment Type"},
      {title: "Link to SMID"}
    ]
  });

}

function edit_profile(dbuser_id){
  $('#change_user_data_form').attr('style', 'display');
  $('#edit_first_name').attr('style', 'display');
  $('#edit_last_name').attr('style', 'display');
  $('#edit_email').attr('style', 'display');
  $('#edit_organization').attr('style', 'display');
  $('#edit_username').attr('style', 'display');

  $('#change_user_data_button').html("Submit New Changes");
  $('#change_user_data_button').attr("onclick", "submit_profile_changes("+dbuser_id+")");
}

function submit_profile_changes(dbuser_id){

  $.ajax({
    url: '/rest/user/'+dbuser_id+'/change_profile',
    data: {
      'first_name' : $('#edit_first_name').val(),
      'last_name' : $('#edit_last_name').val(),
      'email_address' : $('#edit_email').val(),
      'organization' : $('#edit_organization').val(),
      'username' : $('#edit_username').val(),
    },
    success: function(r){
      if (r.error){
        alert(r.error);
      }
      else {
        alert("New data successfully stored.");
        location.reload();
      }

    },
    error: function(r){
      alert("Sorry, an error occurred. "+r.responseText);
      location.reload();
    },
  });

}

function change_password(dbuser_id){
  $('#change_password_form').attr('style', 'display');
  $('#old_password').attr('style', 'display');
  $('#new_password').attr('style', 'display');
  $('#new_password_confirm').attr('style', 'display');

  $('#change_password_button').html("Submit Password Changes");
  $('#change_password_button').attr("onclick", "submit_new_password("+dbuser_id+")");
}

function submit_new_password(dbuser_id){
  $.ajax({
    url: '/rest/user/'+dbuser_id+'/change_password',
    data: {
      'old_password' : $('#old_password').val(),
      'new_password' : $('#new_password').val(),
      'new_password_confirm' : $('#new_password_confirm').val(),
    },
    success: function(r){
      if (r.error){
        alert(r.error);
      }
      else {
        alert("New password successfully stored.");
        location.reload();
      }

    },
    error: function(r){
      alert("Sorry, an error occurred. "+r.responseText);
      location.reload();
    },
  });
}

function submit_new_user_data(){
  $.ajax({
    url:'/rest/user/new',
    data: {
      'first_name' : $('#edit_first_name').val(),
      'last_name' : $('#edit_last_name').val(),
      'email_address' : $('#edit_email').val(),
      'organization' : $('#edit_organization').val(),
      'username' : $('#edit_username').val(),
      'password' : $('#new_password').val(),
      'confirm_password' : $('#new_password_confirm').val(),
      'user_type' : $('#edit_user_type').val(),
    },
    success: function(r){
      if (r.error){alert(r.error);}
      else{
        alert(r.success);
        location.reload();
      }
    },
    error: function(r){
      alert("Sorry, an error occurred. "+r.responseText);
      location.reload();
    }
  })
}
