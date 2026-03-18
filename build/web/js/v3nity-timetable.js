/*jshint -W079*/

'use strict';

var Timetable = function() {
    this.scope = {
        hourStart: 9,
        hourEnd: 17
    };
    this.locations = [];
    this.events = [];

    this.htmlDivs = [];    // kevin added...
};

Timetable.Renderer = function(tt) {
    if (!(tt instanceof Timetable)) {
        throw new Error('Initialize renderer using a Timetable');
    }
    this.timetable = tt;
};

(function() {
    function isValidHourRange(start, end) {
        return isValidHour(start) && isValidHour(end);
    }
    function isValidHour(number) {
        return isInt(number) && isInHourRange(number);
    }
    function isInt(number) {
        return number === parseInt(number, 10);
    }
    function isInHourRange(number) {
        return number >= 0 && number < 24;
    }
    function locationExistsIn(loc, locs) {
        return locs.indexOf(loc) !== -1;
    }
    function isValidTimeRange(start, end) {
        var correctTypes = start instanceof Date && end instanceof Date;
        var correctOrder = start < end;
        return correctTypes && correctOrder;
    }

    Timetable.prototype = {
        setScope: function(start, end) {
            if (isValidHourRange(start, end)) {
                this.scope.hourStart = start;
                this.scope.hourEnd = end;
            }
            else {
                throw new RangeError('Timetable scope should consist of (start, end) in whole hours from 0 to 23');
            }

            return this;
        },
        on: function(event, handler) {
            if (event === 'timelineClick') {
                this.timelineClick = handler;
            }
        },
        addLocations: function(newLocations, newHtmlDivs) {
            function hasProperFormat() {
                return newLocations instanceof Array;
            }

            var existingLocations = this.locations;

            this.htmlDivs = newHtmlDivs;

            if (hasProperFormat()) {
                newLocations.forEach(function(loc) {
                    if (!locationExistsIn(loc, existingLocations)) {
                        existingLocations.push(loc);
                    }
                    else {
                        throw new Error('Location already exists');
                    }
                });
            }
            else {
                throw new Error('Tried to add locations in wrong format');
            }

            return this;
        },
        addEvent: function(name, location, start, end, url, className, onclick) {
            if (!locationExistsIn(location, this.locations)) {
                throw new Error('Unknown location');
            }
            if (!isValidTimeRange(start, end)) {
                throw new Error('Invalid time range: ' + JSON.stringify([start, end]));
            }

            this.events.push({
                name: name,
                location: location,
                startDate: start,
                endDate: end,
                url: url,
                className: className,
                onclick: onclick
            });

            return this;
        }
    };

    function emptyNode(node) {
        while (node.firstChild) {
            node.removeChild(node.firstChild);
        }
    }

    function prettyFormatHour(hour) {
        var prefix = hour < 10 ? '0' : '';
        return prefix + hour + ':00';
    }

    Timetable.Renderer.prototype = {
        draw: function(selector) {
            function getScopeDurationHours(startHour, endHour) {
                return endHour > startHour ? endHour - startHour : 24 + endHour - startHour;
            }
            function checkContainerPrecondition(container) {
                if (container === null) {
                    throw new Error('Timetable container not found');
                }
            }
            function appendTimetableAside(container) {
                var asideNode = container.appendChild(document.createElement('aside'));
                var asideULNode = asideNode.appendChild(document.createElement('ul'));
                appendRowHeaders(asideULNode);
            }
            function appendRowHeaders(ulNode) {
                for (var k = 0; k < timetable.locations.length; k++) {
                    var liNode = ulNode.appendChild(document.createElement('li'));

                    /* original code...
                     var spanNode = liNode.appendChild(document.createElement('span'));
                     spanNode.className = 'row-heading';
                     spanNode.textContent = timetable.locations[k];
                     */

                    /*
                     * kevin added...
                     */
                    var spanNode = liNode.appendChild(document.createElement('div'));
                    spanNode.className = 'row-heading full-size';
                    spanNode.innerHTML = timetable.htmlDivs[k];
                }
            }
            function appendTimetableSection(container) {
                var sectionNode = container.appendChild(document.createElement('section'));

                /*
                 * kevin handles the event when the timeline is clicked...
                 */
                sectionNode.addEventListener('click', function(e) {

                    var el = getMousePosition(this);

                    var x = e.clientX - el.x;

                    var y = e.clientY - el.y;

                    var time = x / (sectionNode.scrollWidth / 24);

                    var i = Math.floor((y - 48) / ((sectionNode.scrollHeight - 48) / timetable.locations.length));

                    if (i >= 0) {
                        var id = timetable.locations[i];    // gets the driver id...

                        var hour = time | 0;

                        var min = Math.abs(Math.round((time % 1) * 60));

                        // beautify the time format...
                        time = (hour < 10 ? '0' : '') + hour + ':' + (min < 10 ? '0' : '') + min;

//                        timetable.timelineClick({id: id, hour: hour, min: min, time: time});
                    }
                });

                var timeNode = sectionNode.appendChild(document.createElement('time'));
                appendColumnHeaders(timeNode);
                appendTimeRows(timeNode);
            }
            function appendColumnHeaders(node) {
                var headerNode = node.appendChild(document.createElement('header'));
                var headerULNode = headerNode.appendChild(document.createElement('ul'));

                var completed = false;
                var looped = false;

                for (var hour = timetable.scope.hourStart; !completed; ) {
                    var liNode = headerULNode.appendChild(document.createElement('li'));
                    var spanNode = liNode.appendChild(document.createElement('span'));
                    spanNode.className = 'time-label';
                    spanNode.textContent = prettyFormatHour(hour);

                    if (hour === timetable.scope.hourEnd && (timetable.scope.hourStart !== timetable.scope.hourEnd || looped)) {
                        completed = true;
                    }
                    if (++hour === 24) {
                        hour = 0;
                        looped = true;
                    }
                }
            }
            function appendTimeRows(node) {
                var ulNode = node.appendChild(document.createElement('ul'));
                ulNode.className = 'room-timeline';
                for (var k = 0; k < timetable.locations.length; k++) {
                    var liNode = ulNode.appendChild(document.createElement('li'));
                    appendLocationEvents(timetable.locations[k], liNode);/**/
                }
            }
            function appendLocationEvents(location, node) {
                for (var k = 0; k < timetable.events.length; k++) {
                    var event = timetable.events[k];
                    if (event.location === location) {
                        appendEvent(event, node);
                    }
                }
            }
            function appendEvent(event, node) {
                var hasURL = event.url;
                var elementType = hasURL ? 'a' : 'span';
                var aNode = node.appendChild(document.createElement(elementType));
                //var smallNode = aNode.appendChild(document.createElement('small'));
                aNode.title = event.name;
                if (hasURL) {
                    aNode.href = event.url;
                }
                aNode.onclick = event.onclick; // kevin added...
                aNode.className = 'time-entry ' + event.className;  // kevin added class name...
                aNode.style.width = computeEventBlockWidth(event);
                aNode.style.left = computeEventBlockOffset(event);
                //smallNode.textContent = event.name;   // kevin commented this... no need to show text on the block...
            }
            function computeEventBlockWidth(event) {
                var start = event.startDate;
                var end = event.endDate;
                var durationHours = computeDurationInHours(start, end);
                return durationHours / scopeDurationHours * 100 + '%';
            }
            function computeDurationInHours(start, end) {
                return (end.getTime() - start.getTime()) / 1000 / 60 / 60;
            }
            function computeEventBlockOffset(event) {
                var start = event.startDate;
                var startHours = start.getHours() + (start.getMinutes() / 60);
                return (startHours - timetable.scope.hourStart) / scopeDurationHours * 100 + '%';
            }

            var timetable = this.timetable;
            var scopeDurationHours = getScopeDurationHours(timetable.scope.hourStart, timetable.scope.hourEnd);
            var container = document.querySelector(selector);
            checkContainerPrecondition(container);
            emptyNode(container);
            appendTimetableAside(container);
            appendTimetableSection(container);
        }
    };

})();

