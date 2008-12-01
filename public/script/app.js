/* cribbed from http://nullstyle.com/2007/06/02/caching-time_ago_in_words */
function time_ago_in_words(from) {
  return distance_of_time_in_words(new Date(), new Date(from)) 
}

function distance_of_time_in_words(to, from) {
  seconds_ago = ((to  - from) / 1000);
  minutes_ago = Math.floor(seconds_ago / 60);

  if(minutes_ago <= 0) { return "less than a minute"; }
  if(minutes_ago == 1) { return "a minute"; }
  if(minutes_ago < 45) { return minutes_ago + " minutes"; }
  if(minutes_ago < 90) { return "1 hour"; }
  hours_ago  = Math.round(minutes_ago / 60);
  if(minutes_ago < 1440) { return hours_ago + " hours"; }
  if(minutes_ago < 2880) { return "1 day"; }
  days_ago  = Math.round(minutes_ago / 1440);
  if(minutes_ago < 43200) { return days_ago + " days"; }
  if(minutes_ago < 86400) { return "1 month"; }
  months_ago  = Math.round(minutes_ago / 43200);
  if(minutes_ago < 525960) { return months_ago + " months"; }
  if(minutes_ago < 1051920) { return "1 year"; }
  years_ago  = Math.round(minutes_ago / 525960);
  return "over " + years_ago + " years" 
}

function clearField(e) {
  if (e.cleared) { return; }
  e.cleared = true;
  e.value = '';
  e.style.color = '#333';
}