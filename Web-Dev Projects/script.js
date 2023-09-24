const dayList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"];
const hourList = ["9am", "10am", "11am", "12pm", "1pm", "2pm", "3pm", "4pm"];

onPageLoad();

/**
 *  Called when page first loads
 *  Renders calendar and populates form with correct values
 */
function onPageLoad() {
  drawCalendar();
  setupEventListeners();
  populateTimes();
  populateLengthSelector(hourList.length + 1);
}

/**
 * Draws the calendar using the globally defined days and hours and adds to DOM
 */
function drawCalendar() {
  const weekElement = document.querySelector("#week");
  for (let day of dayList) {
    const dayElement = drawDay(day);
    weekElement.appendChild(dayElement);
  }
}

/**
 *  Set up event listeners on elements defined in HTML page
 */
function setupEventListeners() {
  const addEventButton = document.querySelector("#add_event_button");
  addEventButton.addEventListener("click", handleAddEventClick);

  const startTimeSelector = document.querySelector("#start_time");
  startTimeSelector.addEventListener("change", handleStartTimeChange);
}

/**
 * Placeholder method that could be used to pre-populate the event form
 */
function handleHourClick(evt) {
  const currentTarget = evt.currentTarget;
  const day = currentTarget.parentElement.parentElement.dataset.day;
  const startTime = currentTarget.dataset.hour;
  const eventDaySelector = document.querySelector("#day");
  const eventStartTimeSelector = document.querySelector("#start_time");
  eventDaySelector.value = day;
  eventStartTimeSelector.value = startTime;
  handleStartTimeChange();
}

/**
 *  Handles when the time element is changed
 */
function handleStartTimeChange() {
  const startTimeSelector = document.querySelector("#start_time");
  const startTime = startTimeSelector.value;
  const hourIndex =
    startTime !== "" ? hourList.findIndex((x) => x === startTime) : 0;
  const allowedHours = hourList.length - hourIndex + 1;
  populateLengthSelector(allowedHours);
}

/**
 *  Handles a click on an added event
 *  Current removes the event
 */
function handleEventClick(evt) {
  const eventElement = evt.currentTarget;
  eventElement.remove();
}

/*
 * Handles the user clicking on the Add Event button
 * Gathers the relevant information about the event to be added and pass it to method to add event
 */
function handleAddEventClick(evt) {
  const eventName = document.querySelector("#event_name").value;
  const eventDay = document.querySelector("#day").value;
  const eventStartTime = document.querySelector("#start_time").value;
  const eventLength = document.querySelector("#length").value;

  if (!checkEventCollision(eventDay, eventStartTime, eventLength)) {
    addEvent(eventName, eventDay, eventStartTime, eventLength);
  } else {
    window.alert(
      "That would conflict with another event. Please choose a different timeframe"
    );
  }
}

/**
 * Given event info, creates an event on the calendar
 */
function addEvent(eventName, day, startTime, length) {
  const daySelector = "[data-day='" + day + "']";
  const dayElement = document.querySelector(daySelector);
  const hourSelector = "[data-hour='" + startTime + "']";
  const hourElement = dayElement.querySelector(hourSelector);
  // Fancy math to account for padding
  let eventHeight = 1.75 + (length - 1) * 2.1;

  // Create the event element, label it, and a listener for future actions
  const event = document.createElement("div");
  event.classList.add("event");
  event.textContent = eventName;
  hourElement.appendChild(event);
  event.addEventListener("click", handleEventClick);

  // Span the event across the given hours
  event.style.height = eventHeight.toString() + "em";
}

/**
 *  Given proposed event info, returns true if it will overlap with an exist event. Otherwise false.
 */
function checkEventCollision(day, startTime, eventLength) {
  const daySelector = "[data-day='" + day + "']";
  const dayElement = document.querySelector(daySelector);
  const hourSelector = "[data-hour='" + startTime + "']";
  let hourElement = dayElement.querySelector(hourSelector);
  let collision = false;
  let i = 0;

  // Since we add event nodes as child nodes to the hour elements,
  // we can loop over the requested time frame, looking for the presence of a child node to determine
  // if there will be a conflict
  while (!collision && i < eventLength) {
    if (hourElement.firstElementChild != null) {
      collision = true;
      break;
    } else {
      hourElement = hourElement.nextElementSibling;
    }
    i++;
  }
  return collision;
}

/*
 * Given a day name, creates a day DOM element and returns it
 */
function drawDay(dayName) {
  const dayElement = document.createElement("div");
  dayElement.setAttribute("class", "day");
  dayElement.setAttribute("data-day", dayName);
  const titleElement = document.createElement("h2");
  const dayNameNode = document.createTextNode(dayName);
  titleElement.appendChild(dayNameNode);
  dayElement.appendChild(titleElement);
  const hourListElement = document.createElement("div");
  hourListElement.setAttribute("class", "hour_block");
  dayElement.appendChild(hourListElement);
  for (let hour of hourList) {
    const hourElement = drawHour(hour);
    hourListElement.appendChild(hourElement);
  }

  return dayElement;
}

/*
 * Given an hour as a string, creates an hour DOM element and returns it
 */
function drawHour(hour) {
  const hourElement = document.createElement("div");
  hourElement.setAttribute("class", "hour");
  hourElement.setAttribute("data-hour", hour);
  hourElement.addEventListener("click", handleHourClick);

  return hourElement;
}

/**
 *  Given the number of allowed hours, populates the length selector appropriately
 */
function populateLengthSelector(allowedHours) {
  const lengthSelector = document.querySelector("#length");

  // Remove existing options
  while (lengthSelector.firstChild) {
    lengthSelector.removeChild(lengthSelector.lastChild);
  }
  // Add new options
  for (let i = 1; i < allowedHours; i++) {
    const optionElement = document.createElement("option");
    optionElement.setAttribute("value", i);
    optionElement.textContent = i.toString() + " hour" + (i > 1 ? "s" : "");
    lengthSelector.appendChild(optionElement);
  }
}

/**
 * Draws the hours on the left of the calendar and in the add event dropdown
 */
function populateTimes() {
  // Draw hours on the left
  const hourColumnElement = document.querySelector("#hour_column");
  const startTimeSelector = document.querySelector("#start_time");

  // Add hours to the event form dropdown
  for (const hour of hourList) {
    const divElement = document.createElement("div");
    divElement.textContent = hour;
    hourColumnElement.appendChild(divElement);

    const optionElement = document.createElement("option");
    optionElement.setAttribute("value", hour);
    optionElement.textContent = hour;
    startTimeSelector.appendChild(optionElement);
  }

  // Dirty hack to get 5pm into left column
  const divElement = document.createElement("div");
  divElement.textContent = "5pm";
  hourColumnElement.appendChild(divElement);
}