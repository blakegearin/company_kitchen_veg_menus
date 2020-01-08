$(document).ready(function() {
  // Changes what's active on the navbar
  $('a[href="' + this.location.pathname + '"]').parents('li,ul').addClass('active');

  applyPreferences();
});


function getKeyByValue(object, value) {
  return Object.keys(object).find(key => object[key] === value);
}

// Prevents hitting enter on input box from clicking the next button
$("#include div div input").bind( "keyup", function() {
  // Number 13 is the "Enter" key on the keyboard
  if (event.keyCode === 13) {
    // Cancel the default action
    event.preventDefault();

    $("#include-button").click();
  }
});

// Prevents hitting enter on input box from clicking the next button
$("#exclude div div input").bind( "keyup", function() {
  // Number 13 is the "Enter" key on the keyboard
  if (event.keyCode === 13) {
    // Cancel the default action
    event.preventDefault();

    $("#exclude-button").click();
  }
});

// Toggles whether an allergy is selected
function toggleAllergy(element) {
  var id = element.id;
  var value = element.innerHTML;
  var button = $(`[id='${id}']`);
  var unselected = button.hasClass("btn-outline-danger");

  if (unselected) {
    activateAllergy(button, id, value);
    setPreference(id, true);
  } else {
    button.addClass("btn-outline-danger");
    button.removeClass("btn-danger");
    document.getElementById(id).innerHTML = id;
    eraseCookie(id);
  }
}

// Enables an allergy button
function activateAllergy(button, id, value) {
  button.addClass("btn-danger");
  button.removeClass("btn-outline-danger");
  document.getElementById(id).innerHTML = `${value} <span aria-hidden='true'>&times;</span>`;
}

// Hides feedback message for a required input item
function removeFeedback(rowClass) {
  $(`.${rowClass} .invalid-feedback`).hide();
}

// Checks if more menu options should be displayed
function checkForCustom() {
  var selected = $("#type option:selected").text();

  if (selected === "Custom") {
    $("#custom").slideDown('', function() {
      $("#more-options").hide();
      $(`#include-input`).focus();
    });
  } else {
    var type = getCookie('type');
    var isVisible = $("#custom").is(":visible");

    if (type !== null && type !== "Custom" && isVisible) {
      showCustom();
    } else if (type !== null && type === "Custom") {
      $("#more-options").show();
      showCustom();
    } else {
      $("#more-options").show();
      hideCustom();
    }
  }
}

// Toggles which input rows are shown based on the selected menu type
function toggleCustom() {
  var selected = $("#type option:selected").text();

  var isVisible = $("#custom").is(":visible");

  if (isVisible) {
    hideCustom();
  } else {
    showCustom();
  }
}

// Hides more menu options
function hideCustom() {
  $("#more-options i").removeClass("fa-angle-up").addClass("fa-angle-down");
  $("#more-options span").html("More Options");
  $("#custom").slideUp();
}

// Shows more menu options
function showCustom() {
  $("#more-options i").removeClass("fa-angle-down").addClass("fa-angle-up");
  $("#more-options span").html("Less Options");
  $("#custom").slideDown();
}

// Removes special characters for security
function sanitizeString(str) {
  var str = str.replace(/[^a-z0-9áéíóúñü \.,_-]/gim,"");
  return str.trim();
}

// Processes an include or exclude word from input
function addWord(type) {
  var input = $(`#${type}-input`).val();

  // Stop if input is empty
  if (input === "") {
    return;
  }

  // Remove special characters except commas
  var input_sanitized = sanitizeString(input).replace(/[^\w\s,]/gi, "");

  // Divide input by commas
  var input_split = input_sanitized.split(/[\s,]+/);

  for (string of input_split) {
    createWordButton(type, string, `${type}-${string}`);
    setPreference(`${type}-${string}`, "true");
  }

  // Clear input and put focus back on input
  $(`#${type}-input`).val("");
  $(`#${type}-input`).focus();
}

var priceSymbols = {
  "eq": "=",
  "gt": ">",
  "lt": "<",
  "ge": "≥",
  "le": "≤"
}

// Processes a price from input
function addPrice() {
  var input_element = $(`#price-input`);

  var input_value = input_element.val();
  var input_float = parseFloat(input_value);

  if (isNaN(input_float)) {
    $(`#price .invalid-feedback`).show();
    return;
  }

  var priceSymbol = $("#price-select").val();
  var symbolText = getKeyByValue(priceSymbols, priceSymbol);

  var button_string = priceSymbol + " " + input_float;
  createWordButton("price", button_string, `price-${symbolText}-${input_value}`);

  input_element.val("");
  input_element.focus();
}

// Creates a button and inserts it into the appropriate place
function createWordButton(type, string, id) {
  var exists = $(`#${id}`).length !== 0;
  if (!exists) {
    var btn = document.createElement("BUTTON");

    btn.id = id;
    btn.type = "button";
    btn.classList.add("btn");
    btn.classList.add("rounded");

    if (type === "include") {
      btn.classList.add("btn-outline-success");
    } else if (type === "exclude") {
      btn.classList.add("btn-outline-danger");
    } else if (type === "price") {
      btn.classList.add("btn-outline-primary");
    }

    btn.innerHTML = string + " <span aria-hidden='true'>&times;</span>";
    btn.onclick = function () {
      this.parentElement.removeChild(this);
      eraseCookie(this.id);
    };

    $(`#${type}-entered`).append(btn);
  }
}

// Gets the IDs of children elements
function getIDs(search) {
  return $(search).map(
    function() {
      return $(this).text().split(' ')[0];
    }
  ).get();
}

// Applies previously entered values/selections to form
function applyPreferences() {
  applyPreference("select#campus", "campus", "select");
  applyPreference("select#type", "type", "select");

  $('#allergies div').children('button').each(
    function(i) {
      var cookieName = this.id
      var id = `#${cookieName}`
      applyPreference(id, cookieName, "button");
    }
  );

  var includeFlag = false;
  var excludeFlag = false;

  for (var cookieName in getCookies()) {
    if (cookieName.includes("include-")) {
      var id = `#${cookieName}`
      applyPreference(id, cookieName, "include");
      includeFlag = true;
    } else if (cookieName.includes("exclude-")) {
      var id = `#${cookieName}`
      applyPreference(id, cookieName, "exclude");
      excludeFlag = true;
    }
  };

  if (includeFlag) {
    $(`#include-input`).focus();
  } else if (excludeFlag) {
    $(`#exclude-input`).focus();
  }
}

function applyPreference(elementIdentifier, cookieName, type) {
  var element = $(elementIdentifier);
  if (element.length === 1 || type === "include" || type === "exclude") {
    var cookie = getCookie(cookieName);
    var foundCookie = cookie !== null;

    if (foundCookie) {
      if (type === "select") {
        element.val(cookie);
        if (cookieName === "type" && cookie === "Custom") {
          $("#more-options").hide();
          $("#custom").slideDown();
        }
      } else if (type === "button") {
        activateAllergy(element, elementIdentifier.replace('#', ''), element.text());
      } else if (type === "include") {
        showCustom();
        var type = "include";
        var string = cookieName.replace('include-', '');
        createWordButton(type, string, `${type}-${string}`);
      } else if (type === "exclude") {
        showCustom();
        var type = "exclude";
        var string = cookieName.replace('exclude-', '');
        createWordButton(type, string, `${type}-${string}`);
      }
    }
  }
}

// Creates a new cookie for a preference
function setPreference(id, value) {
  var foundCookie = getCookie(id) !== null;
  if (foundCookie) {
    eraseCookie(id);
  }
  setCookie(id, value, 14);
}

// Validates that a required input item isn't missing
function validateRequiredInput(elementToValidate) {
  var missingTitle = $(`button[data-id=${elementToValidate}]`).attr("title")  === undefined

  if (missingTitle ) {
    $(`.${elementToValidate} .invalid-feedback`).show();
  }
}

// Builds & executes the path to the menu
function buildMenu() {
  validateRequiredInput("campus");
  validateRequiredInput("type");

  var campus = $("#campus").find("option:selected").text().toLowerCase().trim();
  var type = $("#type").find("option:selected").text().toLowerCase().trim();
  var route = `/campus/${campus}/menu?type=${type}`;

  var completeExcludeArray = [];

  var allergyExists = $("#allergies div button.btn-danger").length !== 0;
  var excludeFlag = allergyExists;
  if (allergyExists) {
    var allergyArray = getIDs("#allergies div button.btn-danger");
    allergyArray = allergyArray.map(item => item.split(' ')).flat()
    completeExcludeArray.push(allergyArray);
  }

  var customIsVisible = $("#custom").is(":visible");
  if (customIsVisible) {
    var includeExists = $("#include-entered").children().length !== 0;
    if (includeExists) {
      var includeArray = getIDs("#include-entered button");
      route += `&include=${includeArray.join(",")}`;
    }

    var excludeExists = $("#exclude-entered").children().length !== 0;
    var excludeFlag = excludeExists;
    if (excludeExists) {
      var excludeArray = getIDs("#exclude-entered button");
      completeExcludeArray.push(excludeArray);
    }

    var priceExists = $("#price-entered").children().length !== 0;
    if (priceExists) {
      var priceArray = $("#price-entered").children('button');

      $.each(
        priceArray,
        function() {
          var pricePair = this.id.replace("price-", "").split("-");
          route += `&${pricePair[0]}=${pricePair[1]}`;
        }
      );
    }
  }

  if (excludeFlag) {
    route += `&exclude=${completeExcludeArray.join(",")}`;
  }

  console.log(route);
  window.open(route, "_self");
}

function showLoading() {
  $('#cover-spin').show(0);
}
