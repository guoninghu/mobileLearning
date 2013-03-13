$('document').ready(function() {
  $('#submit').click(function() {
    $.ajax({url: "/user/login",
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {
        name: $.trim($("#name").val()),
        password: $.trim($("#password").val())
      },
      success: function(data) {
        if (data["errorMsg"] == null) {
          window.location.href = "/";
        } else {
          $("#errorMsg").html(data["errorMsg"]);
        }
      },
      dataType: "json"
    } );
  } );
} );
