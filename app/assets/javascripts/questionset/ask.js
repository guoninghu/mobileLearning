var submitted;
var questionSetId;
var words;
var questions;
var questionIds;
var qId;
var targetIndex;
var questionIndex;
var grade;
var targetDisplay;
var competitorDisplay;

function htmlWord(word) {
  var target = word;
  target[0] = target[0].toUpperCase();
  return '<h1 style="color:Maroon; margin-left:50px">' + target + '</h1>';
}

function htmlImage(image) {
  var targetImage = "/assets/vocabPics/" + image;
  return '<img height="160" src="' + targetImage + '">';
}

function htmlAudio(audio) {
  var targetAudio = "/audios/vocabAudios/" + audio;
  return '<audio id="targetAudio" src="' + targetAudio + '.mp3"></audio>' +
    '<div style="margin:20px 0 20px 60px;"><a onclick="playAudio(\'#targetAudio\')"><img height="90" src="/assets/icons/sound.png"></a></div>';
}

function playAudio(id) {
  $('#targetAudio')[0].play();
  return false;
}

function updateHtml(id, word, type) {
  if (type == 2) {
    var content = htmlWord(word.word);
    $(id).html(content);
  } else if (type == 1) {
    content = htmlImage(word.grade + "/" + word.picture);
    $(id).html(content);
  } else if (type == 3) {
    content = htmlAudio(word.grade + "/" + word.audio);
    $(id).html(content);
  }
}

function setQuestion() {
  qId = questionIds[questionIndex];
  var question = questions[qId];
  var order = question.order;
  var qWordIds = question.words;
  
  // Update target word
  updateHtml('#targetWord', words[qWordIds[0]], targetDisplay);

  $('#answerTrueImage').attr('style', 'display:none');
  $('#answerFalseImage').attr('style', 'display:none');
  $('#nextQuestion').attr("style", "display:none");

  // Update target image
  for (var i=0; i<order.length; i++) {
    if (order[i] == 0) targetIndex = i+1;

    var wordId = qWordIds[order[i]];
    var answerId = '#answer' + (i+1);
    updateHtml(answerId, words[wordId], competitorDisplay);
    
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

      if (data["qType"] == 1) {
        targetDisplay = 2;
        competitorDisplay = 1;
      } else if (data["qType"] == 2) {
        targetDisplay = 3;
        competitorDisplay = 1;
      }
   
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
