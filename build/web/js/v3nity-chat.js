/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */
var ChatClient = function(input, sender, callbacks, options)
{
    var ws = null;
    var typingTimeout = null;
    var inputElementId = '#' + input;

    /*
     * default options...
     */
    var _options = {
        /*
         * indicates the url end point of the chat server...
         */
        endPoint: 'localhost:8080/v3nity4/chat',
        /*
         * indicates the maximum text length to send to the server. if the outcome length is greater then the specified length, the text will be truncated.
         */
        maxLength: 200,
        /*
         * indicates the timeout in seconds when the user stops typing before notifying callback...
         */
        typingTimeout: 5
    };

    /*
     * default callback functions...
     */
    var _callbacks = {
        /*
         * notify when the web socket is opened...
         * @returns {undefined}
         */
        onopen: function()
        {},
        /*
         * notify when the web socket is closed...
         * @returns {undefined}
         */
        onclose: function()
        {},
        /*
         * notify when incoming messages from the server...
         * @returns {undefined}
         */
        onreceive: function(data)
        {
            data = {};
        },
        /*
         * notify when a recipient is typing something...
         *
         *
         * @returns {undefined}
         */
        ontyping: function(yes, id)
        {
            /*
             * if yes = true, indicates that the recipient is typing...
             *
             *   <true> represents the recipient is typing
             *   <false> represents the recipient has stopped typing
             */
            yes = false;

            /*
             * indicates the id of someone is typing...
             */
            id = 0;
        },
        /*
         * gets the array of recipient ids whenever is needed...
         * @returns {Array}
         */
        getrecipients: function()
        {
            return [];
        }
    };

    callbacks = $.extend(_callbacks, callbacks);

    options = $.extend(_options, options);

    var _this = {
        initialize: function()
        {
            $(inputElementId).keypress(function(e)
            {
                if (e.charCode >= 32 && e.charCode <= 127)
                {
                    if (typingTimeout === null)
                    {
                        /*
                         * notify server that user is typing...
                         */
                        _this.send({
                            type: 2,
                            recipients: callbacks.getrecipients()
                        });
                    }
                    else
                    {
                        clearTimeout(typingTimeout);
                    }

                    /*
                     * sets a timer so that the typing event will eventually timeout...
                     */
                    typingTimeout = setTimeout(function()
                    {
                        typingTimeout = null;

                        _this.send({
                            type: 3,
                            recipients: callbacks.getrecipients()
                        });
                    }, options.typingTimeout * 1000);
                }
                else
                {
                    e.preventDefault();
                }
            });
        },
        supportability: function()
        {
            return ("WebSocket" in window);
        },
        dispose: function()
        {
            $(inputElementId).off('keypress');

            if (typingTimeout !== null)
            {
                clearTimeout(typingTimeout);
            }
        },
        connect: function()
        {
            ws = new WebSocket('ws://' + options.endPoint + '/' + sender);

            ws.onopen = function()
            {
                callbacks.onopen();
            };

            ws.onmessage = function(e)
            {
                var data = JSON.parse(e.data);

                /*
                 * indicates normal messages...
                 */
                if (data.type === 1)
                {
                    data.content = escapeTags(data.content);

                    callbacks.onreceive(data);
                }
                /*
                 * indicates user has started typing...
                 */
                else if (data.type === 2)
                {
                    callbacks.ontyping(true, data.sender);
                }
                /*
                 * indicates user has stopped typing...
                 */
                else if (data.type === 3)
                {
                    callbacks.ontyping(false, data.sender);
                }
            };

            ws.onclose = function()
            {
                _this.dispose();

                callbacks.onclose();
            };
        },
        send: function(e)
        {
            /*
             * e parameter json format:
             *
             * type: <integer> see message types.
             * group: <integer> represents the group id. 0 to indicate no group chat.
             * sender: <integer> represents the id of the sender.
             * sendTime: <long> represents the current timestamp in milliseconds.
             * recipients: <integer array> represents a list of ids of the recipients.
             * content: <string> represents the message to send.
             *
             */
            var data = {
                type: 1,
                group: 0,
                sender: sender,
                sendTime: new Date().getTime(),
                recipients: callbacks.getrecipients(),
                content: ''
            };

            data = $.extend(data, e);

            /*
             * check for maximum length...
             */
            data.content = ellipsisText(data.content, options.maxLength);

            /*
             * send message to server...
             */
            ws.send(JSON.stringify(data));
        }
    };

    /*
     * begin initialization process...
     */
    _this.initialize();

    return _this;
};

