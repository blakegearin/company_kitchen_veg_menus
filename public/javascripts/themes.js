$(document).ready(function() {
  browserDark = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches;
  foundLightThemeCookie = getCookie("dark-theme") === "false";
  foundDarkThemeCookie = getCookie("dark-theme") === "true";

  if ((browserDark && !foundLightThemeCookie) || foundDarkThemeCookie === true) {
    setDarkTheme();
  } else {
    setLightTheme();
  }
});


function setDarkTheme() {
  colorThemeIcon = $("#color-theme");
  colorThemeIcon.removeClass("fa-moon");
  colorThemeIcon.addClass("fa-sun");

  document.body.setAttribute('data-theme', 'dark');
  setCookie("dark-theme", "true", 14);
}

function setLightTheme() {
  colorThemeIcon = $("#color-theme");
  colorThemeIcon.removeClass("fa-sun");
  colorThemeIcon.addClass("fa-moon");

  document.body.setAttribute('data-theme', 'light');
  setCookie("dark-theme", "false", 14);
}

function toggleColorTheme() {
  colorThemeIcon = $("#color-theme");
  currentlyLight = colorThemeIcon.hasClass("fa-moon");

  if (currentlyLight) {
    setDarkTheme(colorThemeIcon);
  } else {
    setLightTheme();
  }
}
