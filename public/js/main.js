function p(msg){
  $('p#messages').text(msg);
}
$(function() {
  $(".cell").hover(
    function() {
      $(this).addClass("hover");
    },
    function(){
      $(this).removeClass("hover");
    }
  );

  var fixClass = 'fix';
  var answeredClass = 'answered';
  var updateElement = null;

  $('#sudoku-99').find('.cell').click(function(e){
    var position = { top: e.pageY+5, left: e.pageX+5 }
    $('#choose-value-dialog').modal({backdrop: false});
    $('#choose-value-dialog').offset(position);
    $('#choose-value-dialog').offset(position);
    p(e.pageX+":"+e.pageY);
    updateElement = this;
  });
  $('#sudoku-99').find('.cell').change(function(e){
    alert('123');
  });
  
  $('#choose-value-dialog').find('.cell').click(function(e){
    p(this.innerText);
    $(updateElement).addClass(fixClass).text(this.innerText);
    $('#choose-value-dialog').modal('hide');
    refreshFixedPointsCount();
  });
  
  $('#null').click(function(){
    clearCell(updateElement);
    $('#choose-value-dialog').modal('hide');
    refreshFixedPointsCount();
  });
  function clearCell(current){
    $(current).text('').removeClass(answeredClass).removeClass(fixClass);
  }
  function getFixedPoints(){
    var fixedPoints = {};
    $('.'+fixClass).each(function(){
      fixedPoints[this.id] = Number(this.innerText);
    });
    return fixedPoints;    
  }
  function validateFixedPoints(){
    var pointsCount = $('.'+fixClass).length+$('.'+answeredClass).length;
    return (pointsCount >= 17 && pointsCount < 81);
  }
  function refreshFixedPointsCount(){
    var pointsCount = $('.'+fixClass).length+$('.'+answeredClass).length;
    $(".values-count").text("values count: "+pointsCount);
  }
  function displayPoints(points, needClass){
    for (var key in points){
      $("#"+key).text(points[key]).addClass(needClass);
    }
  }
  $('button#compute').click(function(){
    if (!validateFixedPoints()){ 
      p("No fixed values!");
      return; 
    }
    $('#process-dialog').modal({backdrop: false});
    var position = { top: 93, left: 733 }
    $('#process-dialog').offset(position);
    $('#process-dialog').offset(position);
    var fixedPoints = getFixedPoints();
    $.get('/sudoku/sudokuresult',{fix_values:fixedPoints},function(result){
      displayPoints(JSON.parse(result), answeredClass);
      //p('get success!'+result);
      $('#process-dialog').modal('hide');
      p('Successful!');
      refreshFixedPointsCount();
    });
  });
  $('button#clear').click(function(){
    $('.'+answeredClass).each(function(){
      clearCell(this);
    });
    $('.'+fixClass).each(function(){
      clearCell(this);
    });
    refreshFixedPointsCount();
    p("Cleared all values in the cells.");
  });
  $('button#record').click(function(){
    if (!validateFixedPoints()){
      p("No fixed values!");
      return; 
    }
    var fixedPoints = getFixedPoints();
    p(JSON.stringify(fixedPoints));
  });
  $('button#example1').click(function(){
    $('button#clear').click();
    var fixedPoints = '{"0_0":5,"1_0":3,"0_1":6,"1_2":9,"2_2":8,"4_0":7,"3_1":1,"4_1":9,"5_1":5,"7_2":6,"0_3":8,"0_4":4,"0_5":7,"4_3":6,"3_4":8,"5_4":3,"4_5":2,"8_3":3,"8_4":1,"8_5":6,"1_6":6,"3_7":4,"4_7":1,"5_7":9,"4_8":8,"6_6":2,"7_6":8,"8_7":5,"7_8":7,"8_8":9}';
    displayPoints(JSON.parse(fixedPoints), fixClass);
    refreshFixedPointsCount();
    p("Added values in the cells as an example, then you just click the Computer button.");
  });
  
  refreshFixedPointsCount();
});
