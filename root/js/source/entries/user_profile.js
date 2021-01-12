function populate_profile_data(user_id){

  $.ajax({
    url: '/rest/user/'+user_id+'/profile',
    success: function(r){
      if(r.error){alert(r.error);}
      else{
        $('#user_name').html(r.data.full_name);
        $('#user_email').html(r.data.email_address);
        $('#user_type').html(r.data.user_role);
        $('#user_organization').html(r.data.user_organization);
      }
    },
    error: function(r){
      alert("Sorry, an error occurred."+r.responseText);
    }
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

function edit_profile(){
  $('#change_user_data_form').attr('style', 'display');
  $('#edit_first_name').attr('style', 'display');
  $('#edit_last_name').attr('style', 'display');
  $('#edit_email').attr('style', 'display');
  $('#edit_organization').attr('style', 'display');
  $('#edit_password').attr('style', 'display');
  $('#edit_password_confirm').attr('style', 'display');

  $('#change_user_data_button').html("Submit New Changes");
  $('#change_user_data_button').attr("onclick", "submit_profile_changes()");
}

function submit_profile_changes(){

  //Step 1: Grab input, check it, store it
  //Step 2: Once stored, scrub it clean
  //Step 3: Reset to default hidden state
  //Step 4: Reload Page

  $('#change_user_data_form').attr('style', 'display:none');
  $('#edit_first_name').attr('style', 'display:none');
  $('#edit_last_name').attr('style', 'display:none');
  $('#edit_email').attr('style', 'display:none');
  $('#edit_organization').attr('style', 'display:none');
  $('#edit_password').attr('style', 'display:none');
  $('#edit_password_confirm').attr('style', 'display:none');

  $('#change_user_data_button').html("Edit Your Profile");
  $('#change_user_data_button').attr("onclick", "edit_profile()");
}
