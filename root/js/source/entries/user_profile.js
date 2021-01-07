function populate_profile_data(user_id){

  $.ajax({
    url: '/rest/user/'+user_id+'/profile',
    success: function(r){
      if(r.error){alert(r.error);}
      else{
        console.log(r.data);
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
