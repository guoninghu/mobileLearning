var submitted;
var questionSetId;
var words;
var questions;
var questionIds;
var qId;
var targetIndex;
var questionIndex;
var grade;

function setQuestion() {
  qId = questionIds[questionIndex];
  var question = questions[qId];
  var order = question.order;
  var qWordIds = question.words;
  
  // Update target word
  var target = words[qWordIds[0]].word;
  target[0] = target[0].toUpperCase();
  $('#targetWord').html(target);

  $('#answerTrueImage').attr('style', 'display:none');
  $('#answerFalseImage').attr('style', 'display:none');
  $('#nextQuestion').attr("style", "display:none");

  // Update target image
  for (var i=0; i<order.length; i++) {
    if (order[i] == 0) targetIndex = i+1;

    var wordId = qWordIds[order[i]];
    targetImage = "/assets/vocabPics/" + grade + "/" + words[wordId].picture;
    var answerId = '#answer' + (i+1);
    $(answerId).html('<img height="160" src="' + targetImage + '">');
    $(answerId).parent().buttonMarkup({"theme":"e"});
    $(answerId).buttonMarkup({"theme":"e"}).button("refresh");
  }

  questionIndex ++;
  submitted = false;
}

$('document').ready(function() {
  var qSetTypeId = $('#questionSetTypeId').attr('value');
  grade = $('#grade').attr('value');

  $.ajax({url: '/questionset/' + qSetTypeId + '/start?grade='+grade, success: function(data) {
    words = data["words"];
      questions = data["questions"];
      questionIds = data["questionIds"];
      questionSetId = data["questionSetId"];
      questionIndex = 0;
   
      setQuestion();
      
      $('#questionContent').attr('style', 'visibility:visible');
      return false;
  } });

  $('.submit').click(function() {
    if (submitted) return false;
    submitted = true;

    var answer = $(this).val();
    var imageId = (parseInt(answer) == targetIndex) ? "answerTrueImage" : "answerFalseImage";
    $('#' + imageId).attr("style", "");

    var str = (questionIndex < questionIds.length) ? "Next" : "Done"; 
    $('#nextQuestionIcon').html(str).button("refresh");
    $('#nextQuestion').attr("style", "");
        
    var answerId = "answer" + targetIndex;
    $('#' + answerId).parent().removeClass('ui-btn-hover-e').removeClass('ui-btn-up-e').addClass('ui-btn-up-b').buttonMarkup({"theme":"b"});
    $('#' + answerId).removeClass('ui-btn-up-e').addClass('ui-btn-up-b').buttonMarkup({"theme":"b"});

    $.ajax({ url: "/question/" + qId + "/answer", 
      type: 'POST',
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
      },
      data: {"answer": answer}
    });
    return false;
  });

  $('#nextQuestionIcon').click(function() {
    if (questionIndex < questionIds.length) {
      setQuestion();
    } else {
      window.location.href = '/questionset/' + questionSetId + '/summary';
    }

    return false;
  });
});
