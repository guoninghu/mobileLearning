var grades = new Array("basic", "3rdgrade");

$('document').ready(function() {
  $('select').change(function() {
    var selectedGrade = $('#grade').val();
    for (var index = 0; index < grades.length; index++) {
      if (grades[index] == selectedGrade) {
        $('#' + grades[index]).attr("style", "");
      } else {
        $('#' + grades[index]).attr("style", "display:none");
      }
    }
  });
});
