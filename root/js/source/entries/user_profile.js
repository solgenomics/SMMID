function populate_profile_data(user_id){

  $.ajax({
    url: '/rest/user/'+user_id+'/profile',
    success: function(r){
      if(r.error){alert(r.error);}
      else{
        $('#user_name').html(r.data.full_name);
        $('#user_email').html(r.data.email_address);
        $('#user_type').html(r.data.user_role);
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
