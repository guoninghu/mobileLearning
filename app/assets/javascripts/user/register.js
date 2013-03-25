$('document').ready(function() {
  $('#submit').click(function() {
    alert("OK");
    $.ajax({url: "/user/register",
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {
        name: $.trim($("#name").val()),
        email: $.trim($("#email").val()),
        password: $.trim($("#password").val()),
        password2: $.trim($("#password2").val())
      },
      success: function(data) {
        alert(data);
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
