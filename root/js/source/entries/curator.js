

function curator_html() {

      $('#new_account_button').attr('style', 'display');
      $('#go_to_group_management').attr('style', 'display');

      $('#browse_c_smid_data_div').DataTable({
        'ajax': 'rest/curator/datatable',
        'paging': true,
        'lengthMenu': [[10, 25, 50, 100, -1],[10, 25, 50, 100, "All"]],
        'searching': true,
        'info': true,
        //data: r.data,
        columns: [
          {title: "Compound ID", width: "14%"},
          {title: "SMID ID", width: "14%"},
          {title: "Formula", width: "14%"},
          {title: "Action", width: "14%"},
          {title: "Visibility", width: "14%"},
          {title: "Action", width: "14%"},
          {title: "Curation Status"}
        ]
      });

  	}

function curate_smid(compound_id){
    //$('#curate_'+compound_id).prop('disabled', true);
    //$('#unverify_'+compound_id).prop('disabled', false);
    $.ajax({
      url: '/rest/smid/'+compound_id+'/curate_smid',
      data: {
  	    'curation_status' : "curated",
      },
      success: function(r){
        if (r.error) {alert(r.error);}
        else{
          $('#browse_c_smid_data_div').DataTable().ajax.reload();
        }
      }
    });
  }

  function mark_smid_for_review(compound_id){
    //$('#curate_'+compound_id).prop('disabled', false);
    //$('#unverify_'+compound_id).prop('disabled', true);
    $.ajax({
      url: 'rest/smid/'+compound_id+'/mark_for_review',
      data: {
  	    'curation_status' : "review"
      },
      success: function(r){
        if (r.error){alert(r.error);}
        else {
          $('#browse_c_smid_data_div').DataTable().ajax.reload();
        }
      }
    });
  }

  function change_public_status(compound_id, new_status){

    if (new_status == 'protected'){
      populate_group_select_modal(compound_id);
    } else {
      $.ajax({
        url: 'rest/smid/'+compound_id+'/change_public_status',
        data: {
          'public_status' : new_status,
        },
        error: function(r){
          alert("Sorry, an error occurred. "+r.responseText);
        },
        success: function(r){
          if(r.error) {
            alert(r.error);
          }
          else{
            $('#browse_c_smid_data_div').DataTable().ajax.reload();
          }
        }
      });
    }
  }

  function populate_group_select_modal(compound_id){
    $.ajax({
      url: '/rest/groups/list_groups',
      success: function(r){
        if (r.error){
          alert(r.error);
        } else {
          $('#select_group').html(r.html);
          $('#submit_protected').html("<button id=\"submit_protected_button\" type=\"button\" class=\"btn btn-primary\" onclick=\"submit_protected("+compound_id+", $('#select_group').val())\">Submit</button>")
          $('#select_group_for_protected_status_modal').modal("show");
        }
      },
      error: function(r){
        alert("Sorry, an error occurred: "+r.responseText);
        location.reload();
      }
    });
  }

  function submit_protected(compound_id, group_id){

    if (group_id == 0){
      return;
    }

    $.ajax({
      url:'/rest/smid/'+compound_id+'/change_public_status',
      data: {
        public_status : 'protected',
        dbgroup_id : group_id
      },
      success: function(r){
        if (r.error){
          alert(r.error);
        } else {
          alert("Successfully update the visibility of this smid and assigned a managment group.");
          location.reload();
        }
      },
      error: function(r){
        alert("Sorry, an error occurred: "+r.responseText);
        location.reload();
      }
    });
  }
