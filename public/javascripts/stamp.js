$(document).ajaxSend(function(event, request, settings) {
  if (settings.type == "GET" || typeof(AUTH_TOKEN) == "undefined") return;
  // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
  settings.data = settings.data || "";
  settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
});

jQuery.fn.change_image = function(image) {
  this.attr("src", this.attr("src").replace(/[^\/]+$/, image));
  return this;
};

var instruction_level = 0;
function next_instructions() {
  instruction_level++;
  $("#instructions").attr("src", "/images/instructions/instruction" + instruction_level + ".gif");
}

function pick_up_stamp(click_event) {
  if (instruction_level == 1) {
    next_instructions();
  }
  $("#stamper a img").change_image("ink.png");
  $("#stamp_cursor").change_image("holding.png").show().css({
    left: (click_event.pageX - 40) + 'px',
    top: (click_event.pageY - 45) + 'px'
  }).click(function(event) {
    stamp_down(event);
  });
  $("body").mousemove(function(event) {
    $("#stamp_cursor").css({
      left: (event.pageX - 40) + 'px',
      top: (event.pageY - 45) + 'px'
    });
  });
}

function stamp_down(event) {
  $("body").unbind("mousemove");
  $("#stamp_cursor").unbind("click").hide();
  if (!document.elementFromPoint) {
    alert("Please upgrade your browser to use this feature.");
  }
  if (navigator.userAgent.indexOf("Firefox") != -1) {
    var element = document.elementFromPoint(event.pageX - window.pageXOffset, event.pageY - window.pageYOffset);
  } else {
    var element = document.elementFromPoint(event.pageX, event.pageY);
  }
  if (element.id.search(/day_/) != -1 && $(element).children("a.mark_link").length > 0 && $(element).children("img").length == 0) {
    if (instruction_level == 2) {
      next_instructions();
    }
    $("#stamp_cursor").change_image("stamping.png").show();
    var p = $(element).position();
    var x = (event.pageX - p.left);
    var y = (event.pageY - p.top);
    $.post($(element).children("a.mark_link").attr("href"), { x: x, y: y }, null, "script");
  } else {
    $("#stamper a img").change_image("ready.png");
  }
}

$(function() {
  $("#owner #calendar td").live("click", function(event) {
    if ($(this).children("a.mark_link").length > 0) {
      if ($(this).children(".mark").length > 0) {
        $.post($(this).children("a.mark_link").attr("href"), { _method: "delete" }, null, "script");
      } else {
        var p = $(this).position();
        var x = (event.pageX - p.left);
        var y = (event.pageY - p.top);
        $.post($(this).children("a.mark_link").attr("href"), { x: x, y: y, skip: true }, null, "script");
      }
    }
    return false;
  });
  
  $("#calendar #month a").live("click", function(event) {
    $.getScript(this.href);
    return false;
  });
  
  $("#stamps a").mouseover(function() {
    $("#stamps h2").text(this.title);
  }).mouseout(function() {
    $("#stamps h2").text("Stamp Collection");
  });
  
  $("#owner #stamper a").click(function(click_event) {
    pick_up_stamp(click_event);
    return false;
  });
  
  if ($("#instructions").length > 0) {
    $("#score").hide();
    instruction_level = 1;
  }
});
