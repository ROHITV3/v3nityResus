/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */
var Form = function(formSelector, menuSelector, options) {
    var counter = 1;

    var o = {
        language: {}
    };

    options = $.extend(o, options);

    var _this = {
        selector: '#' + formSelector,
        options: options,
        menu: new FormMenu('#' + menuSelector, options),
        add: function(field) {
            field.initialize(_this);

        },
        clear: function() {
            $(_this.selector).html('');

            $(_this.menu.selector).html('');

            counter = 1;

        },
        count: function() {
            return $(_this.selector).children().length;
        },
        generateId: function() {
            return counter++;
        },
        extractId: function(str) {
            return str.split('-')[2]; // get only the number...
        },
        mobilize: function() { // this function will provide mobile version html...
            var editableFields = $('[data-editable=false]');

            $(editableFields).find('input, textarea, select').each(function() {
                // we disable those non-editable fields for mobile device...
                this.setAttribute('disabled', true);

            });

        },
        getPreview: function() { // this function returns html of specified fields for mobile to preview in the job screen...
            var previewFields = $('[data-preview=true]');

            // currently only support name and value pair...
            var parent = $('<div/>');

            var container = $('<div/>', {
                class: 'job-preview'
            });

            $(previewFields).each(function() {
                var label = $(this).find('#' + this.id + '-label').html();

                container.append($('<label/>', {
                    class: 'job-preview-name'
                }).html(label));

                var value = '';

                var inputs = $(this).find('input, textarea, select');

                if (inputs !== undefined)
                {
                    for (var i = 0; i < inputs.length; i++)
                    {
                        var input = inputs[i];

                        if (input.tagName.toLowerCase() === 'input')
                        {
                            var type = input.getAttribute('type');

                            if (type === 'checkbox' || type === 'radio')
                            {
                                if (input.checked)
                                {
                                    value = input.getAttribute('value');

                                    container.append($('<label/>', {
                                        class: 'job-preview-value'
                                    }).html(value));

                                }
                            }
                            else if (type === 'text')
                            {
                                value = input.getAttribute('value');

                                container.append($('<label/>', {
                                    class: 'job-preview-value'
                                }).html(value));

                            }
                        }
                        else if (input.tagName.toLowerCase() === 'textarea')
                        {
                            value = input.innerHTML;

                            container.append($('<label/>', {
                                class: 'job-preview-value'
                            }).html(value));

                        }
                        else if (input.tagName.toLowerCase() === 'select')
                        {
                            if (input.options.selectedIndex !== -1)
                            {
                                if ($(this).attr('data-role') == 'beacon')
                                {
                                    value = input.options[input.options.selectedIndex].getAttribute('value');

                                    label = input.options[input.options.selectedIndex].innerHTML;

                                    container.append($('<label/>', {
                                        class: 'job-preview-value-bluetooth',
                                        style: 'display: none;'
                                    }).html(value));

                                    container.append($('<label/>', {
                                        class: 'job-preview-text-bluetooth'
                                    }).html(label));
                                    var beaconHolder = $('<label/>', {
                                        class: 'job-preview-bluetooth-status'
                                    });

                                    container.append(beaconHolder);

                                }
                                else
                                {
                                    value = input.options[input.options.selectedIndex].getAttribute('value');

                                    label = input.options[input.options.selectedIndex].innerHTML;

                                    container.append($('<label/>', {
                                        class: 'job-preview-value',
                                        style: 'display: none;'
                                    }).html(value));

                                    container.append($('<label/>', {
                                        class: 'job-preview-value'
                                    }).html(label));

                                }
                            }
                        }
                    }
                }
            });

            parent.append(container);

            return parent.html();
        },
        getHtml: function() {
            var form = $(_this.selector).clone();

            var container = $('<div/>');

            container.append(form);

            $(form).removeAttr('id');

            $(form).find('.form-field.selected').removeClass('selected');

            $(form).find('input, textarea, select').each(function() {
                if (this.required)
                {
                    this.setAttribute('required', true);

                }
                else
                {
                    this.removeAttribute('required');

                }
                if (this.tagName.toLowerCase() === 'input' && this.hasAttribute('type'))
                {
                    if (this.getAttribute('type') === 'checkbox' || this.getAttribute('type') === 'radio')
                    {
                        if (this.checked)
                        {
                            this.setAttribute('checked', 'checked');

                        }
                        else
                        {
                            this.removeAttribute('checked');

                        }
                    }
                    else if (this.getAttribute('type') === 'text')
                    {
                        // nothing to do here...
                    }
                }
                if (this.tagName.toLowerCase() === 'textarea')
                {
                    // nothing to do here...
                }
                if (this.tagName.toLowerCase() === 'select')
                {
                    $(this).children(':selected').each(function() {
                        // nothing to do here...
                    });

                }
            });

            return $(container).html();
        },
        setHtml: function(html) {
            _this.clear();

            var form = $('<div/>').html(html);

            var fields = form.children().children();

            fields.each(function() {
                var field = $(this);

                var selector = '#' + field.attr('id');

                var id = _this.extractId(selector);

                // always assign the highest id because any additional field will increment from there...
                counter = Math.max(counter, id);

                // must increment by 1...
                counter = counter + 1;

                var options = {
                    id: id,
                    selector: selector,
                    settings: {}
                };

                var role = field.data('role');

                options.preview = field.data('preview');

                options.editable = field.data('editable');

                options.columnize = field.data('columnize');
				options.showall = field.data('showall');

                options.geotag = field.data('geotag');

                options.backup = field.data('backup');

                options.hideimagedate = field.data('hideimagedate'); // for save form one
                options.hideimagetime = field.data('hideimagetime');

                options.compute = field.data('compute');

                options.addedcamera = field.attr('data-addedcamera');
                
                options.keyword = field.attr('data-keyword');

                switch (role)
                {
                    case 'label':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        options.settings.text = elements.eq(3).text();

                        _this.add(new Label(options));

                        break;

                    case 'singleline':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = elements.eq(3);

                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.attr('value');

                        options.settings.id = input.attr('id');

                        _this.add(new SingleLine(options));

                        break;

                    case 'multiline':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = elements.eq(3);
                        
                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.rows = input.attr('rows');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.html();

                        _this.add(new MultiLine(options));

                        break;

                    case 'checkboxes':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var cbContainer = elements.eq(3);

                        options.settings.items = [];

                        options.settings.selections = [];

                        var checkboxes = $(cbContainer).find(':input');

                        $(checkboxes).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).parent().text());

                            if (value.checked)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        _this.add(new Checkboxes(options));

                        break;

                    case 'radiobuttons':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var cbContainer = elements.eq(3);

                        options.settings.items = [];

                        options.settings.selections = [];

                        var radiobuttons = $(cbContainer).find(':input');

                        $(radiobuttons).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).parent().text());

                            if (value.checked)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        _this.add(new Radiobuttons(options));

                        break;

                    case 'selection':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var selectElement = $(elements).find('select');

                        options.settings.items = [];

                        options.settings.selections = [];

                        var items = $(selectElement).children();

                        $(items).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).text());

                            if (value.selected)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        options.settings.id = selectElement.attr('id');

                        //                        options.settings.id = input.attr('id');

                        _this.add(new Selection(options));

                        break;

                    case 'beacon':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var selectElement = $(elements).find('select');

                        options.settings.items = [];

                        options.settings.selections = [];

                        var items = $(selectElement).children();

                        $(items).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).text() + " | " + $(value).val());

                            if (value.selected)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        options.settings.id = selectElement.attr('id');

                        _this.add(new Beacon(options));

                        break;

                    case 'image':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = $(elements).find('img');

                        options.settings.value = input.attr('src');

                        _this.add(new StaticImage(options));

                        break;
                        
                    case 'uploadVideo':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var photoDiv = elements.eq(3);

                        options.settings.min = photoDiv.attr('data-min');

                        options.settings.max = photoDiv.attr('data-max');

                        options.settings.value = $(elements).find('img');

                        options.settings.value.each(function () {
                            if (!($(this).hasClass('imageId')))
                            {
                                $(this).addClass('imageId');

                                $(this).attr('onclick', '$(this).toggleClass(\'selected\');');

                            }
                            if ($(this).hasClass('imageId selected'))
                            {
                                $(this).removeClass('selected');

                            }
                        });

                        _this.add(new UploadVideo(options));

                        break;
                        
                    case 'drawingimage':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = $(elements).find('img');

                        options.settings.value = input.attr('src');

                        _this.add(new ImageDrawing(options));

                        break;

                    case 'gallery':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var photoDiv = elements.eq(3);

                        options.settings.min = photoDiv.attr('data-min');

                        options.settings.max = photoDiv.attr('data-max');

                        options.settings.value = $(elements).find('img');

                        options.settings.value.each(function() {
                            if (!($(this).hasClass('imageId')))
                            {
                                $(this).addClass('imageId');

                                $(this).attr('onclick', '$(this).toggleClass(\'selected\');');

                            }
                            if ($(this).hasClass('imageId selected'))
                            {
                                $(this).removeClass('selected');

                            }
                        });

                        _this.add(new Gallery(options));

                        break;

                    case 'camera':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var photoDiv = elements.eq(3);

                        options.settings.min = photoDiv.attr('data-min');

                        options.settings.max = photoDiv.attr('data-max');

                        options.settings.value = $(elements).find('img');

                        options.settings.value.each(function() {
                            if (!($(this).hasClass('imageId')))
                            {
                                $(this).addClass('imageId');

                                $(this).attr('onclick', '$(this).toggleClass(\'selected\');');

                            }
                            if ($(this).hasClass('imageId selected'))
                            {
                                $(this).removeClass('selected');

                            }
                        });

                        _this.add(new Camera(options));

                        break;
                        
                    case 'capturegeotag':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var photoDiv = elements.eq(3);

                        options.settings.value = $(elements).find('img');

                        options.settings.value.each(function() {
                            if (!($(this).hasClass('imageId')))
                            {
                                $(this).addClass('imageId');

                                $(this).attr('onclick', '$(this).toggleClass(\'selected\');');

                            }
                            if ($(this).hasClass('imageId selected'))
                            {
                                $(this).removeClass('selected');

                            }
                        });

                        _this.add(new CaptureGeotag(options));

                        break;

                    case 'signature':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var sigDiv = elements.eq(3);

                        options.settings.value = $(elements).find('img');

                        _this.add(new Signature(options));

                        break;

                    case 'barcode':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var barcodeDiv = elements.eq(3);

                        options.settings.min = barcodeDiv.attr('data-min');

                        options.settings.max = barcodeDiv.attr('data-max');

                        var barcodeLabel = barcodeDiv.children()[0];

                        options.settings.value = barcodeLabel.innerHTML;

                        options.settings.items = [];

                        var selectElement = $(elements).find('ul');

                        var items = $(selectElement).children();

                        $(items).each(function() {
                            options.settings.items.push($(this).text());

                        });

                        _this.add(new Barcode(options));

                        break;

                    case 'ratings':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var ratingDiv = elements.eq(1);

                        options.settings.max = ratingDiv.attr('data-max');

                        var ratingLabel = ratingDiv.children()[0];

                        options.settings.value = ratingLabel.innerHTML;

                        options.settings.hint = '';

                        options.settings.items = [];

                        options.settings.selections = [];

                        $(ratingDiv).find('div.rating').each(function(index, value) {
                            var ratingItemLabel = $(value).children()[0];

                            options.settings.items.push($(ratingItemLabel).text());

                            if (index === 0)
                            {
                                var ratingHint = $(value).children()[2];

                                options.settings.hint = $(ratingHint).text();

                            }
                            $(value).find('.rating-input').each(function(index, value) {
                                if (value.checked)
                                {
                                    options.settings.selections.push(index);

                                }
                            });

                        });

                        _this.add(new Ratings(options));

                        break;

                    case 'collapser':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.settings.max = field.attr('data-max');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        _this.add(new Collapser(options));

                        break;

                    case 'ratingsSummary':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        _this.add(new RatingsSummary(options));

                        break;

                    case 'email':
                        var elements = field.children();

                        var labelElement = $(elements).first();

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var input = $(elements).next();

                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.attr('value');

                        _this.add(new Email(options));

                        break;

                    case 'email-multiple':
                        var elements = field.children();

                        var labelElement = $(elements).first();

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var cbContainer = $(elements).next();

                        options.settings.items = [];

                        options.settings.selections = [];

                        var checkboxes = $(cbContainer).find(':input');

                        $(checkboxes).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).parent().text());

                            if (value.checked)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        _this.add(new EmailMultiple(options));

                        break;

                    case 'email-selection':
                        var elements = field.children();

                        var labelElement = $(elements).first();

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var selectElement = $(elements).find('select');

                        options.settings.items = [];

                        options.settings.selections = [];

                        var items = $(selectElement).children();

                        $(items).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).text());

                            if (value.selected)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        _this.add(new EmailSelection(options));

                        break;

                    case 'drawing':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var drawDiv = elements.eq(3);

                        options.settings.value = $(elements).find('img');

                        _this.add(new Drawing(options));

                        break;

                    case 'number-keypad':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');
                        
//                        var hint = elements.eq(2);

//                        options.settings.hint = hint.text();

                        var input = elements.eq(1);

                        options.settings.value = input.attr('value');
                        
                        options.settings.placeholder = input.attr('placeholder');

                        _this.add(new NumberKeypad(options));

                        break;
                        
                    case 'number-range':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');
                        
                        var input = elements.eq(1);

                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');
                        
                        options.settings.minimum = input.attr('minimum');

                        options.settings.maximum = input.attr('maximum');

                        options.settings.value = input.attr('value');
                        
                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        _this.add(new NumberRange(options));

                        break;

                    case 'date-picker':
                        var elements = field.children();

                        var labelElement = $(elements).first();

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var input = $(elements).next();

//                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.attr('value');

                        _this.add(new DatePicker(options));

                        break;

                    case 'time-picker':
                        var elements = field.children();

                        var labelElement = $(elements).first();

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var input = $(elements).next();

//                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.attr('value');

                        _this.add(new TimePicker(options));

                        break;

                    case 'date-time-picker':
                       var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = elements.eq(3);

//                        options.settings.placeholder = input.attr('placeholder');

                        options.settings.maxlength = input.attr('maxlength');

                        options.settings.value = input.attr('value');

                        options.settings.id = input.attr('id');

                        _this.add(new DateTimePicker(options));

                        break;

                    case 'iconcheckboxes':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var photoDiv = elements.eq(3);

                        options.settings.min = photoDiv.attr('data-min');

                        options.settings.max = photoDiv.attr('data-max');

                        options.settings.value = $(elements).find('img');

                        var cbContainer = elements.eq(4);

                        options.settings.items = [];

                        options.settings.selections = [];

                        var iconcheckboxes = $(cbContainer).find(':input');

                        $(iconcheckboxes).each(function(index, value) {
                            // get label text...
                            options.settings.items.push($(value).parent().text());

                            if (value.checked)
                            {
                                options.settings.selections.push(index);

                            }
                        });

                        _this.add(new IconCheckbox(options));

                        break;

                    case 'addcamera':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var photoDiv = elements.eq(3);

                        options.settings.min = photoDiv.attr('data-min');

                        options.settings.max = photoDiv.attr('data-max');

                        options.settings.maxAdd = photoDiv.attr('data-maxAdd');

                        options.settings.value = $(elements).find('img');

                        _this.add(new AddCamera(options));

                        break;

                    case 'cameralibrary':
                        var elements = field.children();
                        var labelElement = elements.eq(0);
                        options.label = labelElement.text();
                        options.mandatory = labelElement.hasClass('mandatory');
                        var hint = elements.eq(2);
                        options.settings.hint = hint.text();
                        var photoDiv = elements.eq(3);
                        options.settings.min = photoDiv.attr('data-min');
                        options.settings.max = photoDiv.attr('data-max');
                        options.settings.value = $(elements).find('img');
                        options.settings.value.each(function() {
                            if (!($(this).hasClass('imageId')))
                            {
                                $(this).addClass('imageId');

                                $(this).attr('onclick', '$(this).toggleClass(\'selected\');');

                            }
                            if ($(this).hasClass('imageId selected'))
                            {
                                $(this).removeClass('selected');

                            }
                        });

                        _this.add(new CameraLibrary(options));
                        break;
                        
                    case 'embeddedURL':
                        
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = elements.eq(3);
                        
                        

//                        options.settings.placeholder = input.attr('placeholder');
//
//                        options.settings.maxlength = input.attr('maxlength');

                         options.settings.value = input.attr('value');
                         
                         var frame = elements.eq(4);
                         options.settings.src =  input.attr('value');

                        options.settings.id = input.attr('id');

                        _this.add(new EmbeddedURL(options));

                        break;
                        
                    case 'otp':
                        
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var input = elements.eq(3);
                        
                        options.settings.value = input.attr('value');
                         
                        var otpVal = elements.eq(6);
                       
                        options.settings.otpVal =  otpVal.attr('value');
                       
                        _this.add(new OTPField(options));

                        break;
                        
                    case 'timeCapture':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        options.settings.text = elements.eq(3).text();

                        _this.add(new TimeCapture(options));

                        break;
                        
                    
                    case 'file':
                        var elements = field.children();

                        var labelElement = elements.eq(0);

                        options.label = labelElement.text();

                        options.mandatory = labelElement.hasClass('mandatory');

                        var hint = elements.eq(2);

                        options.settings.hint = hint.text();

                        var anchor = $(elements).find('a');

                        options.settings.value = anchor.attr('href');
                        
                        options.settings.fileName = anchor.html();

                        _this.add(new File(options));

                        break;
                }
            });

        }
    };

    return _this;
};

var FormMenu = function(selector, options) {
    var _this = {
        selector: selector,
        noDelete: false,
        options: options,
        add: function(fieldMenu) {
            fieldMenu.initialize();

            var html = fieldMenu.createBase();

            $(_this.selector).append(html);

        }
    };

    return _this;
};

var FormFieldMenu = function(_id, _formMenu, formMenuTitle) {
    var _this = {
        id: _id,
        selector: '#formfieldmenu' + _id,
        formMenu: _formMenu,
        formMenuTitle: formMenuTitle,
        enableMandatory: true,
        enablePreview: true,
        enableEditable: true,
        enableColumnize: false,
        enableGeotag: false,
        enableBackup: false,
        hideImageDate: false,
        hideImageTime: false,
        enableCompute: false,
        enableKeyword: "",
        enableShowall:false,
        createBase: function(field) {
            var fieldMenu = $('<div/>', {
                id: _this.selector.substring(1),
                class: 'form-field-menu'
            });

            /*
             * creates toolbar...
             */
            var toolbar = _this.createToolbar(field);

            fieldMenu.append(toolbar);

            if (_this.formMenuTitle !== undefined)
            {
                fieldMenu.append('<h2 class="text-light">' + _this.formMenuTitle + '</h2>');

            }
            /*
             * creates label input...
             */
            fieldMenu.append('<label>' + _this.formMenu.options.language.formEditorTitle + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var inputLabel = $('<input/>', {
                type: 'text',
                name: 'name',
                maxlength: 500,
                value: field.label
            }).on('change', function() {
                $(field.selector + '-label').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputLabel.change();

            inputContainer.append(inputLabel);

            fieldMenu.append(inputContainer);
            
            
            fieldMenu.append('<label>' + _this.formMenu.options.language.formEditorKeyword + '</label>');

            inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });
            
            var inputKeyword = $('<input/>', {
                type: 'text',
                name: 'name',
                maxlength: 500,
                value:field.keyword,
            }).on('change', function () {
                var input = $(this).val();
                $(field.selector).attr('data-keyword', input);

            });
                            // make the change immediately to take effect on the form field...
            inputKeyword.change();

            inputContainer.append(inputKeyword);

            fieldMenu.append(inputContainer);

            /*
             * creates mandatory input...
             */
            if (_this.enableMandatory)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputMandatory = $('<input/>', {
                    id: _this.selector.substring(1) + '-mandatory',
                    type: 'checkbox',
                    checked: field.mandatory
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector + '-label').toggleClass('mandatory', checked);

                    $(field.selector).find('input, textarea, select, div.photo, div.image').each(function() {
                        if (this.tagName.toLowerCase() === 'div')
                        {
                            $(this)[0].setAttribute('required', checked); // cannot use jquery .attr because the value will become 'required'
                        }
                        else
                        {
                            this.required = checked;

                        }
                    });

                });

                // make the change immediately to take effect on the form field...
                inputMandatory.change();

                inputContainer.append(inputMandatory);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorMandatory));

                fieldMenu.append(inputContainer);

            }
			 if (_this.enableShowall)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });
                
                
                //debugger;

                var inputShowall = $('<input/>', {
                    //id: _this.selector.substring(1) + '-showall',
                    type: 'checkbox',
                    checked: field.showall
                }).on('change', function() {
                   var checked = $(this).is(':checked');

                    $(field.selector).attr('data-showall', checked);
                    
                      this.required = checked;

                    

                });

                // make the change immediately to take effect on the form field...
                inputShowall.change();

                inputContainer.append(inputShowall);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorShowAll));

                fieldMenu.append(inputContainer);

            }
            
            /*
             * creates preview input...
             */
            if (_this.enablePreview)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputPreview = $('<input/>', {
                    type: 'checkbox',
                    checked: field.preview
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-preview', checked);

                });

                // make the change immediately to take effect on the form field...
                inputPreview.change();

                inputContainer.append(inputPreview);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorPreview));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates editable input...
             */
            if (_this.enableEditable)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputEditable = $('<input/>', {
                    type: 'checkbox',
                    checked: field.editable
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-editable', checked);

                });

                // make the change immediately to take effect on the form field...
                inputEditable.change();

                inputContainer.append(inputEditable);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorEditable));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates visible column input...
             */
            if (_this.enableColumnize)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputColumnize = $('<input/>', {
                    type: 'checkbox',
                    checked: field.columnize
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-columnize', checked);

                });

                // make the change immediately to take effect on the form field...
                inputColumnize.change();

                inputContainer.append(inputColumnize);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorColumnize));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates geotag image
             */
            if (_this.enableGeotag)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputGeotag = $('<input/>', {
                    type: 'checkbox',
                    checked: field.geotag
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-geotag', checked);

                });

                // make the change immediately to take effect on the form field...
                inputGeotag.change();

                inputContainer.append(inputGeotag);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorGeotag));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates backup of camera image
             */
            if (_this.enableBackup)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputBackup = $('<input/>', {
                    type: 'checkbox',
                    checked: field.backup
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-backup', checked);

                });

                // make the change immediately to take effect on the form field...
                inputBackup.change();

                inputContainer.append(inputBackup);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorBackup));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates image date
             */
            if (_this.hideImageDate)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputDate = $('<input/>', {
                    type: 'checkbox',
                    checked: field.hideimagedate
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-hideimagedate', checked);

                });

                // make the change immediately to take effect on the form field...
                inputDate.change();

                inputContainer.append(inputDate);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorImageDate));

                fieldMenu.append(inputContainer);

            }
            /*
             * creates image time
             */
            if (_this.hideImageTime)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var inputTime = $('<input/>', {
                    type: 'checkbox',
                    checked: field.hideimagetime
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-hideimagetime', checked);

                });

                // make the change immediately to take effect on the form field...
                inputTime.change();

                inputContainer.append(inputTime);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorImageTime));

                fieldMenu.append(inputContainer);

            }
            /*
             * create compute
             */
            if (_this.enableCompute)
            {
                inputContainer = $('<label/>', {
                    class: 'input-control checkbox'
                });

                var compute = $('<input/>', {
                    type: 'checkbox',
                    checked: field.compute
                }).on('change', function() {
                    var checked = $(this).is(':checked');

                    $(field.selector).attr('data-compute', checked);

                });

                // make the change immediately to take effect on the form field...
                compute.change();

                inputContainer.append(compute);

                inputContainer.append($('<span/>', {
                    class: 'check'
                }));

                inputContainer.append($('<span/>', {
                    class: 'caption'
                }).append(' ' + _this.formMenu.options.language.formEditorCompute));

                fieldMenu.append(inputContainer);

            }
            /*
             * execute custom creation... NOT IN USE !!!
             */
            _this.create(field);

            fieldMenu.hide();

            $(_this.formMenu.selector).append(fieldMenu);

            return;
        },
        createToolbar: function(field) {
            var toolbar = $('<div/>', {
                class: 'toolbar'
            });

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            });

            if (!_this.formMenu.noDelete)
            {
                var buttonRemove = $('<button/>', {
                    type: 'button',
                    class: 'toolbar-button',
                    title: _this.formMenu.options.language.formEditorToolbarDelete
                }).html('<span class="mif-bin"></span>').on('click', function() {
                    _this.remove(field);

                });

                toolbarSection.append(buttonRemove);

                toolbarSection.append(' '); // must add this manually...
            }
            var buttonMoveUp = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.formMenu.options.language.formEditorToolbarMoveUp
            }).html('<span class="mif-arrow-up"></span>').on('click', function() {
                _this.moveup(field);

            });

            toolbarSection.append(buttonMoveUp);

            toolbarSection.append(' '); // must add this manually...
            var buttonMoveDown = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.formMenu.options.language.formEditorToolbarMoveDown
            }).html('<span class="mif-arrow-down"></span>').on('click', function() {
                _this.movedown(field);

            });

            toolbarSection.append(buttonMoveDown);

            toolbar.append(toolbarSection);

            return toolbar;
        },
        create: function(field) {
            /*
             * creates user-defined elements through inheritance... (NOT IN USE !!!)
             */
            return field;
        },
        moveup: function(field) {
            var prevField = $(field.selector).prev();

            _this.swap($(field.selector), $(prevField));

        },
        movedown: function(field) {
            var nextField = $(field.selector).next();

            _this.swap($(field.selector), $(nextField));

        },
        remove: function(field) {
            if ($(field.selector).attr('data-role') === 'collapser')
            {
                var count = $(field.selector).attr('data-max');

                //if (!$(field.selector).children().first().hasClass('expand')) { // if it is not expanded, delete all the thing inside  (Tested before)
                $(field.selector).nextAll(':lt(' + count + ')').each(function() {
                    $(this).remove();

                });

                $(_this.selector).nextAll(':lt(' + count + ')').each(function() {
                    $(this).off();

                    $(this).remove();

                });

                //}
            }
            field.remove(); // this will remove the actually html from the right side
            $(_this.selector).off(); // this will remove the menu (left side) formfieldmenu
            $(_this.selector).remove();

        },
        show: function() {
            $('.form-field-menu').hide();

            $(_this.selector).show();

        },
        hide: function() {
            $(_this.selector).hide();

        },
        swap: function(a, b) {
            var tmp = $('<span>').hide();

            a.before(tmp);

            b.before(a);

            tmp.replaceWith(b);

        }
    };

    return _this;
};
function getTextAreaLineNumber(textarea) {
    var t = $(textarea)[0];

    return t.value.substr(0, t.selectionStart).split("\n").length;
}
/* --------------------------------
 *
 * Base Class for Form Fields
 *
 * --------------------------------
 */
var FormField = function() {
    var _this = {
        form: null,
        fieldMenu: null,
        fieldMenuTitle: '',
        role: 'base',
        id: 0,
        selector: '',
        label: null,
        mandatory: false,
        preview: false,
        editable: true,
        columnize: false,
        geotag: false,
        backup: false,
        compute: false,
        keyword:'',
        showall:false,
        initialize: function(_form) {
            _this.form = _form;

            if (_this.label === null)
            {
                _this.label = _form.options.language.formEditorTitle;

            }
            
            if (_this.keyword === '')
            {
                _this.keyword = _form.options.language.formEditorKeyword;
            }
            
            if (_this.selector === '')
            {
                _this.id = _form.generateId();

                _this.selector = '#form-field-' + _this.id;

            }
            _this.fieldMenu = new FormFieldMenu(_this.id, _this.form.menu, _this.fieldMenuTitle);

            _this.createBase();

            _this.fieldMenu.createBase(_this);

            _this.createMenu(_this);

        },
        createBase: function() {
            var field = $('<div/>', {
                id: _this.selector.substring(1),
                class: 'form-field',
                'data-role': _this.role,
                'data-preview': _this.preview,
                'data-editable': _this.editable,
                'data-keyword': _this.keyword
            }).on('click', function() {
                $('.form-field').removeClass('selected');

                field.addClass('selected');

                _this.fieldMenu.show();

            });

            var label = $('<label/>', {
                id: _this.selector.substring(1) + '-label',
                class: 'form-field-label'
            }).html(_this.label);

            field.append(label);

            _this.create(field);

            $(_this.form.selector).append(field);

        },
        create: function(field) {
            /*
             * creates user-defined elements through inheritance...
             */
            return field;
        },
        createMenu: function(parent) {
            /*
             * creates user-defined elements through inheritance...
             */
            return parent;
        },
        remove: function() {
            $(_this.selector).off();

            $(_this.selector).remove();

        },
        appendButtons: function(field) {
            var btnRemove = $('<button/>', {
                type: 'button',
                id: _this.selector + 'removebutton',
                class: 'button form-buttons'
            }).html('<span class="mif-bin"></span>');

            $(field).append(btnRemove);

            $(btnRemove).on('click', function() {
                _this.remove();

            });

        }
    };

    return _this;
};

/* --------------------------------
 *
 * Inherit Classes for Form Fields
 *
 * --------------------------------
 */
var Label = function(options) {
    var _this = {
        role: 'label',
        fieldMenuTitle: 'Label',
        settings: {
            text: '',
            hint: null
        },
        input: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<label/>');

            field.append(_this.input);

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;
			
			_this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            /*
             * creates placeholder input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorText + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            var inputText = $('<textarea/>', {
                rows: 3
            }).on('change', function() {
                _this.input.html(this.value);

            });

            // preset the value for the input text...
            inputText.val(_this.settings.text);

            // make the change immediately to take effect on the form field...
            inputText.change();

            var field = $(parent.selector);

            inputContainer.append(inputText);

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var SingleLine = function(options) {
    var _this = {
        role: 'singleline',
        fieldMenuTitle: 'Single Line',
        settings: {
            placeholder: '',
            maxlength: 50,
            value: '',
            id: '',
            hint: null
        },
        input: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<input/>', {
                type: 'text',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);

            //_this.appendButtons(field);

            _this.fieldMenu.enableColumnize = true;

            _this.fieldMenu.enableCompute = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates placeholder input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorPlaceholder + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var inputLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.placeholder
            }).on('change', function() {
                _this.input.attr("placeholder", this.value);

            });

            // make the change immediately to take effect on the form field...
            inputLabel.change();

            inputContainer.append(inputLabel);

            fieldMenu.append(inputContainer);

            /*
             * creates characters limit input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorCharacterLimit + '</label>');

            inputContainer = $('<div/>');

            var inputMaxLen = $('<input/>', {
                type: 'range',
                min: 0,
                max: 200,
                value: _this.settings.maxlength
            }).on('change', function() {
                _this.input.attr("maxlength", this.value);

            });

            inputMaxLen.on('mousemove', function() {
                $(inputMaxLen).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMaxLen.change();

            inputContainer.append(inputMaxLen);

            inputContainer.append($('<span/>').html(_this.input.attr('maxlength')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            /*
             * creates ID input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorId + '</label>');

            var idContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var idLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.id,
                disabled: 'true'
            }).on('change', function() {
                _this.input.attr("id", this.value);

            });

            idLabel.change();

            idContainer.append(idLabel);

            fieldMenu.append(idContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var MultiLine = function(options) {
    var _this = {
        role: 'multiline',
        fieldMenuTitle: 'Multi-Line',
        settings: {
            placeholder: '',
            maxlength: 50,
            rows: 3,
            value: '',
            hint: null
        },
        input: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<textarea/>', {
                rows: 3,
                maxlength: 50
            }).html(_this.settings.value).on('change', function() {
                _this.input.html(this.value);

            });

            field.append(_this.input);

            _this.fieldMenu.enableColumnize = true;

            _this.fieldMenu.enableCompute = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);
            
            /*
             * creates placeholder input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorPlaceholder + '</label>');
            
            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var inputLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.placeholder
            }).on('change', function() {
                _this.input.attr("placeholder", this.value);

            });

            // make the change immediately to take effect on the form field...
            inputLabel.change();

            inputContainer.append(inputLabel);

            fieldMenu.append(inputContainer);

            /*
             * creates rows input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorLines + '</label>');

            var inputContainer = $('<div/>');

            var inputRows = $('<input/>', {
                type: 'range',
                min: 3,
                max: 10,
                value: _this.settings.rows
            }).on('change', function() {
                _this.input.attr("rows", this.value);
            });

            inputRows.on('mousemove', function() {
                $(inputRows).siblings('span').html(this.value);
            });

            // make the change immediately to take effect on the form field...
            inputRows.change();

            inputContainer.append(inputRows);

            inputContainer.append($('<span/>').html(_this.input.attr('rows')));

            fieldMenu.append(inputContainer);

            /*
             * creates characters limit input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorCharacterLimit + '</label>');

            inputContainer = $('<div/>');

            var inputMaxLen = $('<input/>', {
                type: 'range',
                min: 0,
                max: 2000,
                value: _this.settings.maxlength
            }).on('change', function() {
                _this.input.attr("maxlength", this.value);

            });

            inputMaxLen.on('mousemove', function() {
                $(inputMaxLen).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMaxLen.change();

            inputContainer.append(inputMaxLen);

            inputContainer.append($('<span/>').html(_this.input.attr('maxlength')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Checkboxes = function(options) {
    var _this = {
        role: 'checkboxes',
        fieldMenuTitle: 'Checkboxes',
        settings: {
            items: [],
            selections: [],
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            var fieldset = $('<fieldset/>'); // special request from mobile side...
            var checkboxLabel = $('<label/>');

            if (_this.settings.items.length === 0)
            {
                _this.settings.items.push(_this.form.options.language.formEditorTitle);

            }
            checkboxLabel.append($('<input/>', {
                type: 'checkbox',
                id: '0',
                value: _this.form.options.language.formEditorTitle
            }));

            checkboxLabel.append(_this.form.options.language.formEditorTitle);

            fieldset.append(checkboxLabel);

            container.append(fieldset);

            field.append(container);

            _this.fieldMenu.enableColumnize = true;
			_this.fieldMenu.enableShowall = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var toolbar = $(fieldMenu).find('.toolbar');

            /*             creates textarea for checkboxes input...             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorItems + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            var inputCheckboxes = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                var container = $('<div/>', {
                    class: 'checkboxes'
                });

                var fieldset = $('<fieldset/>'); // special request from mobile side...
                field.find('.checkboxes').remove();

                var lines = this.value.split('\n');

                for (var i = 0; i < lines.length; i++)
                {
                    var value = lines[i];

                    var checkboxLabel = $('<label/>');

                    checkboxLabel.append($('<input/>', {
                        type: 'checkbox',
                        id: i,
                        value: value
                    }));

                    checkboxLabel.append(value);

                    fieldset.append(checkboxLabel);

                }
                container.append(fieldset);

                field.append(container);
				
				 _this.fieldMenu.enableColumnize = true;
				 _this.fieldMenu.enableShowall = true;

            });

            // preset values to checkboxes...
            inputCheckboxes.val(_this.settings.items.join('\n'));

            // make the change immediately to take effect on the form field...
            inputCheckboxes.change();

            // set selected checkboxes...
            var checkboxFields = field.find('.checkboxes :input');

            for (var j = 0; j < _this.settings.selections.length; j++)
            {
                var index = _this.settings.selections[j];

                var input = checkboxFields[index];

                input.checked = true;

            }
            inputCheckboxes.append('untitled');

            inputContainer.append(inputCheckboxes);

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            /*
             * creates a button to toggle checkboxes using cursor position in the textarea...
             */
            /*
             var buttonToggleCheck = $('<button/>', {type: 'button', class: 'button primary'}).html('<span>Toggle</span>').on('click', function () {
             var line = getTextAreaLineNumber(inputCheckboxes) - 1;
             var input = field.find('.checkboxes :input')[line]; // directly go to the checkbox...
             input.checked = !input.checked;

             });
             fieldMenu.append(buttonToggleCheck);

             */
            var buttonClearDefault = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.form.options.language.formEditorToolbarClearDefault
            }).html('<span class="mif-cross"></span>').on('click', function() {
                var inputs = field.find('.checkboxes :input');

                inputs.removeAttr('checked');

            });

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            }).append(buttonClearDefault);

            toolbar.append(toolbarSection);

        },
        setText: function(container) {
            var text = '';

            $(container).children().each(function() {
                if (text.length > 0)
                {
                    text += '\n';

                }
                text += $(this).val();

            });

            return text;
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Radiobuttons = function(options) {
    var _this = {
        role: 'radiobuttons',
        fieldMenuTitle: 'Radio Buttons',
        settings: {
            items: [],
            selections: [],
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            var fieldset = $('<fieldset/>'); // special request from mobile side...
            var radioLabel = $('<label/>');

            if (_this.settings.items.length === 0)
            {
                _this.settings.items.push(_this.form.options.language.formEditorTitle);

            }
            radioLabel.append($('<input/>', {
                type: 'radio',
                id: '0',
                name: 'radio-' + _this.id,
                value: _this.form.options.language.formEditorTitle
            }));

            radioLabel.append(_this.form.options.language.formEditorTitle);

            fieldset.append(radioLabel);

            container.append(fieldset);

            field.append(container);

            _this.fieldMenu.enableCompute = false;
			
			 _this.fieldMenu.enableColumnize = true;
			 _this.fieldMenu.enableShowall = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var toolbar = $(fieldMenu).find('.toolbar');

            /*
             * creates textarea for radio buttons input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorItems + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            var inputRadios = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                var container = $('<div/>', {
                    class: 'radiobuttons'
                });

                var fieldset = $('<fieldset/>'); // special request from mobile side...
                field.find('.radiobuttons').remove();

                var lines = this.value.split('\n');

                for (var i = 0; i < lines.length; i++)
                {
                    var value = lines[i];

                    var radioLabel = $('<label/>');

                    radioLabel.append($('<input/>', {
                        type: 'radio',
                        id: i,
                        name: 'radio' + _this.id,
                        value: value
                    }));

                    radioLabel.append(value);

                    fieldset.append(radioLabel);

                }
                container.append(fieldset);

                field.append(container);

            });

            // preset values to checkboxes...
            inputRadios.val(_this.settings.items.join('\n'));

            // make the change immediately to take effect on the form field...
            inputRadios.change();

            // set selected radio buttons...
            var radioButtonFields = field.find('.radiobuttons :input');

            for (var j = 0; j < _this.settings.selections.length; j++)
            {
                var index = _this.settings.selections[j];

                var input = radioButtonFields[index];

                input.checked = true;

            }
            inputRadios.append('untitled');

            inputContainer.append(inputRadios);

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            /*
             * creates a button to toggle radiobutton using cursor position in the textarea...
             */
            /*
             var buttonToggleCheck = $('<button/>', {type: 'button', class: 'button primary'}).html('<span>Toggle</span>').on('click', function () {
             var line = getTextAreaLineNumber(inputRadios) - 1;
             var input = field.find('.radiobuttons :input')[line]; // directly go to the radio button...
             input.checked = !input.checked;

             });
             fieldMenu.append(buttonToggleCheck);

             */
            var buttonClearDefault = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.form.options.language.formEditorToolbarClearDefault
            }).html('<span class="mif-cross"></span>').on('click', function() {
                var inputs = field.find('.radiobuttons :input');

                inputs.removeAttr('checked');

            });

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            }).append(buttonClearDefault);

            toolbar.append(toolbarSection);

        },
        setText: function(container) {
            var text = '';

            $(container).children().each(function() {
                if (text.length > 0)
                {
                    text += '\n';

                }
                text += $(this).val();

            });

            return text;
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Selection = function(options) {
    var _this = {
        role: 'selection',
        fieldMenuTitle: 'Selection',
        settings: {
            items: [],
            selections: [],
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            var dropdown = $('<select/>').on('change', function() {
                var storeIndex = this.selectedIndex;

                $(this).children().each(function() {
                    $(this).removeAttr('selected');

                });

                if (storeIndex > -1)
                {
                    // have to do this to update the html before saving. The fucking system won't update itself...
                    $(this).val($(this).children().eq(storeIndex).text()); // this update the value of the selected field

                    this.options[storeIndex].setAttribute('selected', 'selected'); // this update the option attr = selected.
                }
            });

            if (_this.settings.items.length === 0)
            {
                _this.settings.items.push(_this.form.options.language.formEditorTitle);

            }
            dropdown.append($('<option/>', {
                value: _this.form.options.language.formEditorTitle
            }).html(_this.form.options.language.formEditorTitle));

            container.append(dropdown);

            field.append(container);

            _this.fieldMenu.enableColumnize = true;

            _this.fieldMenu.enableCompute = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates textarea for drop down input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorItems + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            var inputDropdown = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                var dropdown = field.find('select');

                $(dropdown).children().remove();

                var lines = this.value.split('\n');

                for (var i = 0; i < lines.length; i++)
                {
                    var value = lines[i];

                    dropdown.append($('<option/>', {
                        value: value
                    }).html(value));

                }
            });

            // preset values to items...
            inputDropdown.val(_this.settings.items.join('\n'));

            // make the change immediately to take effect on the form field...
            inputDropdown.change();

            // set selected items...
            var itemFields = field.find('select').children();

            for (var j = 0; j < _this.settings.selections.length; j++)
            {
                var index = _this.settings.selections[j];

                var input = itemFields[index];

                input.setAttribute('selected', 'selected');

            }
            inputDropdown.append('untitled');

            inputContainer.append(inputDropdown);

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            /*
             * creates a button to toggle item using cursor position in the textarea...
             */
            var buttonToggleCheck = $('<button/>', {
                type: 'button',
                class: 'button primary'
            }).html('<span>Select</span>').on('click', function() {
                var line = getTextAreaLineNumber(inputDropdown) - 1;

                var dropdown = field.find('select');

                var input = $(dropdown).children()[line]; // directly go to the item...
                var checked = ($(input).is(':selected'));

                $(input).prop('selected', !checked);

                // must set this..don't know why!!!
                $(input).attr('selected', 'selected');

            });

            //fieldMenu.append(buttonToggleCheck);

            /*
             * creates ID input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorId + '</label>');

            var idContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var idLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.id,
                disabled: 'true'
            }).on('change', function() {
                var dropdown = field.find('select');

                dropdown.attr("id", this.value);

            });

            idLabel.change();

            idContainer.append(idLabel);

            fieldMenu.append(idContainer);

        },
        setText: function(container) {
            var text = '';

            $(container).children().each(function() {
                if (text.length > 0)
                {
                    text += '\n';

                }
                text += $(this).val();

            });

            return text;
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Beacon = function(options) {
    var _this = {
        role: 'beacon',
        fieldMenuTitle: 'Beacon',
        preview: true,
        editable: false,
        settings: {
            items: [],
            selections: [],
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            var dropdown = $('<select/>', {
                id: ''
            }).on('change', function() {
                for (var i = 0; i < this.options.length; i++)
                {
                    if (i === this.selectedIndex)
                    {
                        this.options[this.selectedIndex].setAttribute('selected', 'selected'); // this update the option attr = selected.
                    }
                    else
                    {
                        this.options[i].removeAttribute('selected', 'selected');

                    }
                }
            });

            if (_this.settings.items.length === 0)
            {
                _this.settings.items.push(_this.form.options.language.formEditorTitle);

            }
            dropdown.append($('<option/>', {
                value: _this.form.options.language.formEditorTitle
            }).html(_this.form.options.language.formEditorTitle));

            container.append(dropdown);

            field.append(container);

            _this.fieldMenu.enableColumnize = true;

            _this.fieldMenu.enableCompute = true;

            _this.fieldMenu.enablePreview = false;

        },
        createMenu: function(parent, container) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            /*
             * creates a button to toggle item using cursor position in the textarea...
             */
            var buttonToggleCheck = $('<button/>', {
                type: 'button',
                class: 'button primary'
            }).html('<span>Select</span>').on('click', function() {
                var line = getTextAreaLineNumber(inputDropdown) - 1;

                var dropdown = field.find('select');

                var input = $(dropdown).children()[line]; // directly go to the item...
                var checked = ($(input).is(':selected'));

                $(input).prop('selected', !checked);

                // must set this..don't know why!!!
                $(input).attr('selected', 'selected');

            });

            /*
             * creates textarea for drop down input...
             */
            var inputContainer = $('<div/>', {
                id: 'device',
                class: 'input-control textarea full-size'
            });

            var dropdown = field.find('select');

            var lines = $(dropdown).children();

            var inputDropdown = $('<textarea/>', {
                disabled: 'true;',
                rows: lines.length
            }).on('change', function() {
                for (var i = 0; i < lines.length; i++)
                {
                    var unit_id = lines[i].value;

                    var label = lines[i].html
                    dropdown.append($('<option/>', {
                        value: unit_id
                    }).html(label));

                }
            });

            // preset values to items...
            inputDropdown.val(_this.settings.items.join('\n'));

            // make the change immediately to take effect on the form field...
            inputDropdown.change();

            var buttonRefresh = $('<button/>', {
                type: 'button',
                class: 'button primary',
                style: 'display: block;'
            }).on('click', function() {
                _this.getid(fieldMenu, field, inputContainer, container);

            });

            buttonRefresh.text(_this.form.options.language.formEditorRefresh);

            fieldMenu.append(buttonRefresh);

            fieldMenu.append('<label>' + _this.form.options.language.formEditorItems + '</label>');

            inputContainer.append(inputDropdown);

            fieldMenu.append(inputContainer);

            buttonRefresh.click();

        },
        setText: function(container) {
            var text = '';

            $(container).children().each(function() {
                if (text.length > 0)
                {
                    text += '\n';

                }
                text += $(this).val();

            });

            return text;
        },
        getid: function(fieldMenu, field, inputContainer, container) {
            var dropdown = field.find('select');

            var getid_URL = "JobFormTemplateController?action=list&type=beacon";

            $.ajax({//ajax call to populate beacon device id
                url: getid_URL,
                timeout: 10000,
                success: function(data) {
                    if (data.result)
                    {
                        if (data.data.length > 0)
                        {
                            inputContainer.empty();

                            $(dropdown).children().remove();

                            var inputDropdown = $('<textarea/>', {
                                id: 'device',
                                rows: data.data.length,
                                disabled: 'true'
                            });

                            for (var i = 0; i < data.data.length; i++)
                            {
                                var label = data.data[i].label;

                                var unit_id = data.data[i].unit_id;

                                if (i === data.data.length)
                                {
                                    inputDropdown.append(label);

                                }
                                else
                                {
                                    inputDropdown.append(label + ' | ' + unit_id + '\n'); // preset values to items
                                }
                                dropdown.append($('<option/>', {
                                    value: unit_id
                                }).html(label));

                            }
                            // set selected items...
                            var itemFields = field.find('select').children();

                            for (var j = 0; j < _this.settings.selections.length; j++)
                            {
                                var index = _this.settings.selections[j];

                                var input = itemFields[index];

                                input.setAttribute('selected', 'selected');

                            }
                            inputContainer.append(inputDropdown);

                            fieldMenu.append(inputContainer);

//                            container.append(dropdown);

//                            field.append(container);

                        }
                    }
                    else
                    {
                        dialog('Error retrieving data', 'alert');

                    }
                },
            });

        },
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var StaticImage = function(options) {
    var _this = {
        role: 'image',
        fieldMenuTitle: 'Image',
        settings: {
            value: '',
            hint: null
        },
        fileSelector: null,
        imageElement: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.fileSelector = $('<input/>', {
                type: 'file'
            }).on('change', _this.handleFile);

            var container = $('<div/>', {
                class: _this.role
            }).on('click', function() {
                _this.fileSelector.click();

            });

            _this.imageElement = $('<img/>', {
                src: _this.settings.value
            });

            container.append(_this.imageElement);

            field.append(container);

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates a button to upload image...
             */
            var buttonUpload = $('<button/>', {
                type: 'button',
                class: 'button primary'
            }).html('<span>' + _this.form.options.language.formEditorBrowse + '</span>').on('click', function() {
                _this.fileSelector.click();

            });

            fieldMenu.append(buttonUpload);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        },
        handleFile: function(e) {
            var file = e.target.files[0]; // only get first file...
            var reader = new FileReader();

            reader.onloadend = function() {
                var url = reader.result;
                _this.imageElement.attr('src', url);
//                resizeImage(url, 300, 300, 0.5, function(url) {
//                    _this.imageElement.attr('src', url);
//
//                });

            };

            if (file)
            {
                var imageType = /image.*/;

                if (file.type.match(imageType))
                {
                    reader.readAsDataURL(file);

                }
                else
                {
                    _this.imageElement.attr('src', '');

                }
            }
            else
            {
                _this.imageElement.attr('src', '');

            }
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Gallery = function(options) {
    var _this = {
        role: 'gallery',
        fieldMenuTitle: 'Gallery',
        settings: {
            value: '',
            min: 0,
            max: 5,
            hint: null
        },
        fileButton: '', // this variable is to identify which button was click for add or replace, if replace then will store the index.
        fileSelector: null,
        imageElement: [],
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role,
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            container.append(_this.settings.value);

            _this.fileSelector = $('<input/>', {
                type: 'file',
                multiple: 'multiple'
            }).on('change', function(e) {
                // Added the read file function here as tried to copy from staticImage to put at handlefile but failed.
                
                var files = e.target.files;
                
                for(var i = 0; i < files.length; i++)
                {
                    var file = files[i];
                    
                    if (typeof file == 'undefined' || typeof file == null)
                    {
                        continue;
                    }
                    
                    if(!file.type.match('image')) continue;
                    
                    var reader = new FileReader();
                    
                    reader.addEventListener("load", function(event){
                    
                        var url = event.target.result;
                    
                        resizeImageCamera(url, 0.5, function(url) {
                        
                            var elementCount = $(_this.selector + ' div.' + _this.role).children().length

                            var dataMax = $(_this.selector + ' div.' + _this.role).attr('data-max');

                            if (elementCount > dataMax)
                            {
                                dialog('Max Images Attached', 'You have reached the max amount of images.', 'alert');

                                return;
                            }

                            if (_this.fileButton === '')
                            { // for add image function
                                
                                _this.imageElement[i] = $('<img/>', {
                                    src: _this.settings.value
                                });

                                _this.imageElement[i].addClass('imageId');
                                function two(num) { //forces number to 2 digits
                                    var num = ("0" + num).slice(-2);

                                    return num;
                                }
                                
                                var now = new Date();

                                var now = two(now.getDate()) + "/" + two(now.getMonth() + 1) + "/" + two(now.getFullYear()) + " " + two(now.getHours()) + ":" + two(now.getMinutes()) + ":" + two(now.getSeconds());

                                _this.imageElement[i].attr('data-timestamp', now);

                                _this.imageElement[i].attr('data-block-unit', '0'); // This field will affect PDF
                                _this.imageElement[i].attr('data-block-level', '0'); //This field will affect PDF
                                _this.imageElement[i].attr('data-latitude', '0');

                                _this.imageElement[i].attr('data-longitude', '0');

                                _this.imageElement[i].css('background-color', 'rgb(0, 0, 0');

                                _this.imageElement[i].attr('onclick', '$(this).toggleClass(\'selected\');');

                                if ($(_this.selector + ' div.' + _this.role).children().hasClass('selected'))
                                { //_this.selector = id
                                    var x = 0;

                                    $(_this.selector + ' div.' + _this.role).children().each(function() { // this code can be further improve to be a single line.
                                        if ($(this).hasClass('selected'))
                                        {
                                            x = $(this).index();

                                            return false;
                                        }
                                    });

                                    _this.imageElement[i].insertBefore(container.find('img').eq(x));

                                }
                                else
                                {
                                    _this.imageElement[i].insertBefore(container.find('input'));

                                    //                                if(container.has('input')){ // will need to consider this after solving the camera img showing after it pass through mobile side
                                    //                                } else{
                                    //                                    container.append(_this.imageElement); // Just in case for those that dont have camera img element inside for old report.
                                    //                                }
                                }
                                _this.imageElement[i].attr('src', url);

                            }
                            else
                            {
                                $(_this.selector + ' div.' + _this.role).children().eq(_this.fileButton).attr('src', url); // for replace image function, get the selected picture and change the src
                            }
                        });         
                
                    });
                
                    //Read the image
                    reader.readAsDataURL(file);
                }
            });

            //Currently remove the following "if check"  (Problem with adding it is that if user add image before scheduling the job, it will cause problem at the mobile phone side)
            //            if (_this.settings.value.length === 0)
            //            {
            //
            // a mobile requirement that sets to use input type image...
            var image = $('<input/>', {
                type: 'image',
                src: 'img/form_gallery.png'
            }).on('click', function() {
                return false;
            });

            container.append(image);

            //            }
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableCompute = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var inputContainer = $('<div/>');

            var inputMin = $('<input/>', {
                type: 'range',
                min: 0,
                max: 20,
                value: _this.settings.min
            }).on('change', function() {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));

                _this.input.attr('data-min', this.value);

            });

            inputMin.on('mousemove', function() {
                $(inputMin).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMin.change();

            inputContainer.append(inputMin);

            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));

            fieldMenu.append(inputContainer);

            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            inputContainer = $('<div/>');

            var inputMax = $('<input/>', {
                type: 'range',
                min: 1,
                max: 20,
                value: _this.settings.max
            }).on('change', function() {
                _this.input.attr('data-max', this.value);

            });

            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMax.change();

            inputContainer.append(inputMax);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            addEditDeleteButton(_this, fieldMenu, _this.role);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var UploadVideo = function (options) {

        var _this = {
        role: 'uploadVideo',
        fieldMenuTitle: 'Upload Video',
        settings: {
            value: '',
            min: 0,
            max: 5
        },
        fileButton: '',
        fileSelector: null,
        imageElement: null,

        create: function (field) {
            var hintVal = $(field.selector + '-hint').html();
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');
            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role,
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            container.append(_this.settings.value);


            var image = $('<input/>', {
                type: 'image',
                src: 'img/form_video1.png'
            }).on('click', function () {
                return false;
            });

            container.append(image);
            
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enablePreview = true;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableCompute = false;
            
            _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function (parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var inputContainer = $('<div/>');

            var inputMin = $('<input/>', {
                type: 'range',
                min: 0,
                max: 20,
                value: _this.settings.min
            }).on('change', function () {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));

                _this.input.attr('data-min', this.value);

            });

            inputMin.on('mousemove', function () {
                $(inputMin).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMin.change();

            inputContainer.append(inputMin);

            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));

            fieldMenu.append(inputContainer);

            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            inputContainer = $('<div/>');

            var inputMax = $('<input/>', {
                type: 'range',
                min: 1,
                max: 20,
                value: _this.settings.max
            }).on('change', function () {
                _this.input.attr('data-max', this.value);

            });

            inputMax.on('mousemove', function () {
                $(inputMax).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMax.change();

            inputContainer.append(inputMax);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var ImageDrawing = function (options) {
    debugger;
    var _this = {
        role: 'drawingimage',
        fieldMenuTitle: 'Image Drawing',
        settings: {
            value: '',
            hint: null
        },
        fileSelector: null,
        imageElement: null,
        create: function (field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',    
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.fileSelector = $('<input/>', {
                type: 'file'
            }).on('change', _this.handleFile);

            var container = $('<div/>', {
                class: _this.role
            }).on('click', function () {
                _this.fileSelector.click();

            });

            _this.imageElement = $('<img/>', {
                src: _this.settings.value
            });

            container.append(_this.imageElement);

            field.append(container);

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;

        },
        createMenu: function (parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates a button to upload image...
             */
            var buttonUpload = $('<button/>', {
                type: 'button',
                class: 'button primary'
            }).html('<span>' + _this.form.options.language.formEditorBrowse + '</span>').on('click', function () {
                _this.fileSelector.click();

            });

            fieldMenu.append(buttonUpload);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function () {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                } else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        },
        handleFile: function (e) {
            var file = e.target.files[0]; // only get first file...
            var reader = new FileReader();

            reader.onloadend = function () {
                var url = reader.result;
                _this.imageElement.attr('src', url);

            };

            if (file)
            {
                var imageType = /image.*/;

                if (file.type.match(imageType))
                {
                    reader.readAsDataURL(file);

                } else
                {
                    _this.imageElement.attr('src', '');

                }
            } else
            {
                _this.imageElement.attr('src', '');

            }
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Camera = function(options) {
    var _this = {
        role: 'camera',
        fieldMenuTitle: 'Camera',
        settings: {
            value: '',
            min: 0,
            max: 5,
            hint: null,
            edit: ''
        },
        fileButton: '', // this variable is to identify which button was click for add or replace, if replace then will store the index.
        fileSelector: null,
        imageElement: [],
        create: function(field) {
            try
            { // this is for dynamic add camera function to check if it is added from mobile through the function
                if (typeof options.addedcamera != 'undefined')
                {
                    field.attr('data-addedcamera', 'true');

                }
            }
            catch (e)
            {
            }
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role,
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            // this fileSelector same as the one used in StaticImage. Help read new upload for Add and Replace Function.
            _this.fileSelector = $('<input/>', {
                type: 'file',
                multiple: 'multiple'
            }).on('change', function (e) {
                // Added the read file function here as tried to copy from staticImage to put at handlefile but failed.
                var files = e.target.files;

                for (var i = 0; i < files.length; i++)
                {
                    var file = files[i];

                    if (typeof file == 'undefined' || typeof file == null)
                    {
                        continue;
                    }

                    if (!file.type.match('image'))
                        continue;

                    var reader = new FileReader();

                    reader.addEventListener("load", function (event) {

                        var url = event.target.result;

                        // resizeImage(url,300,300, 0.5, function (url) { // Different from StaticImage Resize, this re-size all image to 400 x 300 or 300 x 400 depending if it is landscape or potrait.
                        resizeImageCamera(url, 0.5, function (url) {

                            var elementCount = $(_this.selector + ' div.' + _this.role).children().length

                            var dataMax = $(_this.selector + ' div.' + _this.role).attr('data-max');

                            if (elementCount > dataMax)
                            {
                                dialog('Max Images Attached', 'You have reached the max amount of images.', 'alert');

                                return;
                            }

                            if (_this.fileButton === '')
                            { // for add image function
                                _this.imageElement[i] = $('<img/>', {
                                    src: _this.settings.value
                                });

                                _this.imageElement[i].addClass('imageId');
                                function two(num) { //forces number to 2 digits
                                    var num = ("0" + num).slice(-2);

                                    return num;
                                }
                                var now = new Date();

                                var hideImgDate = $(_this.selector).attr('data-hideimagedate');

                                var hideImgTime = $(_this.selector).attr('data-hideimagetime');

                                //attempt to use options.hideimagedate and options.hideimagetime but it wont work for brand new job schedule.
                                if (hideImgDate == 'true' && hideImgTime == 'true')
                                {
                                    var now = "";

                                } else if (hideImgDate == 'true' && hideImgTime == 'false')
                                {
                                    var now = two(now.getHours()) + ":" + two(now.getMinutes()) + ":" + two(now.getSeconds());

                                } else if (hideImgDate == 'false' && hideImgTime == 'true')
                                {
                                    var now = two(now.getDate()) + "/" + two(now.getMonth() + 1) + "/" + two(now.getFullYear());

                                } else
                                {
                                    var now = two(now.getDate()) + "/" + two(now.getMonth() + 1) + "/" + two(now.getFullYear()) + " " + two(now.getHours()) + ":" + two(now.getMinutes()) + ":" + two(now.getSeconds());

                                    //var formatDate = date.getDate().pad(2) + "/" + date.getMonth().pad(2) + "/" + date.getFullYear().toString().substr(-2) + " " + date.getHours().pad(2)+ ":" + date.getMinutes().pad(2) + ":" + date.getSeconds().pad(2);

                                }
                                _this.imageElement[i].attr('data-timestamp', now);

                                _this.imageElement[i].attr('data-block-unit', '0'); // This field will affect PDF
                                _this.imageElement[i].attr('data-block-level', '0'); //This field will affect PDF
                                _this.imageElement[i].attr('data-latitude', '0');

                                _this.imageElement[i].attr('data-longitude', '0');

                                _this.imageElement[i].css('background-color', 'rgb(0, 0, 0');

                                _this.imageElement[i].attr('onclick', '$(this).toggleClass(\'selected\');');

                                if ($(_this.selector + ' div.' + _this.role).children().hasClass('selected'))
                                { //_this.selector = id
                                    var x = 0;

                                    $(_this.selector + ' div.' + _this.role).children().each(function () { // this code can be further improve to be a single line.
                                        if ($(this).hasClass('selected'))
                                        {
                                            x = $(this).index();

                                            return false;
                                        }
                                    });

                                    _this.imageElement[i].insertBefore(container.find('img').eq(x));

                                } else
                                {
                                    _this.imageElement[i].insertBefore(container.find('input'));

                                    // if(container.has('input')){ // will need to consider this after solving the camera img showing after it pass through mobile side
                                    // } else{
                                    // container.append(_this.imageElement); // Just in case for those that dont have camera img element inside for old report.
                                    // }
                                }
                                _this.imageElement[i].attr('src', url);

                            } else
                            {
                                $(_this.selector + ' div.' + _this.role).children().eq(_this.fileButton).attr('src', url); // for replace image function, get the selected picture and change the src
                            }
                        });

                    });

                    //Read the image
                    reader.readAsDataURL(file);
                }

            });

            container.append(_this.settings.value); //adding all the current image into the list
            //Currently remove the following "if check"  (Problem with adding it is that if user add image before scheduling the job, it will cause problem at the mobile phone side)
            // if (_this.settings.value.length === 0) // only when there is no pre-add image, the camera icon will appear for user to add image at mobile side
            //{
            // a mobile requirement that sets to use input type image...
            var image = $('<input/>', {
                type: 'image',
                src: 'img/form_camera.png'
            }).on('click', function() {
                return false;
            });

            container.append(image);

            //}
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enableGeotag = true;

            _this.fieldMenu.enableBackup = true;

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.hideImageDate = true;

            _this.fieldMenu.hideImageTime = true;

            _this.fieldMenu.enableCompute = false;
			
             _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var inputContainer = $('<div/>');

            var inputMin = $('<input/>', {
                type: 'range',
                min: 0,
                max: 20,
                value: _this.settings.min
            }).on('change', function() {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));

                _this.input.attr('data-min', this.value);

            });

            inputMin.on('mousemove', function() {
                $(inputMin).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMin.change();

            inputContainer.append(inputMin);

            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));

            fieldMenu.append(inputContainer);

            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            inputContainer = $('<div/>');

            var inputMax = $('<input/>', {
                type: 'range',
                min: 1,
                max: 20,
                value: _this.settings.max
            }).on('change', function() {
                _this.input.attr('data-max', this.value);

            });

            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMax.change();

            inputContainer.append(inputMax);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);
            
            //*added new buttons for adding/replacing/deleting image for this field.
            addEditDeleteButton(_this, fieldMenu, _this.role);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var CaptureGeotag = function(options) {
    var _this = {
        role: 'capturegeotag',
        fieldMenuTitle: 'Capture Geotag',
        settings: {
            value: '',
            edit: ''
        },
        fileButton: '', // this variable is to identify which button was click for add or replace, if replace then will store the index.
        fileSelector: null,
        imageElement: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');
            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            // this fileSelector same as the one used in StaticImage. Help read new upload for Add and Replace Function.
            _this.fileSelector = $('<input/>', {
                type: 'file'
            }).on('change', function(e) {
                // Added the read file function here as tried to copy from staticImage to put at handlefile but failed.
                var file = e.target.files[0]; // only get first file...
                if (typeof file == 'undefined' || typeof file == null)
                {
                    return;
                }
                var reader = new FileReader();

                reader.onloadend = function() {
                    var url = reader.result;

                    //                    resizeImage(url,300,300, 0.5, function (url) { // Different from StaticImage Resize, this re-size all image to 400 x 300 or 300 x 400 depending if it is landscape or potrait.

                };

                if (file)
                {
                    var imageType = /image.*/;

                    if (file.type.match(imageType))
                    {
                        reader.readAsDataURL(file);

                    }
                    else
                    {
                        _this.imageElement.attr('src', '');

                    }
                }
                else
                {
                    _this.imageElement.attr('src', '');

                }
                // Original Code
                // container.prepend(_this.imageElement); // used prepend instead of append so as not to mess up the mobile code
                //field.append(container);

            });

            container.append(_this.settings.value); //adding all the current image into the list
            //Currently remove the following "if check"  (Problem with adding it is that if user add image before scheduling the job, it will cause problem at the mobile phone side)
            // if (_this.settings.value.length === 0) // only when there is no pre-add image, the camera icon will appear for user to add image at mobile side
            //{
            // a mobile requirement that sets to use input type image...
            var image = $('<input/>', {
                type: 'image',
                src: 'img/form_map.png'
            }).on('click', function() {
                return false;
            });

            container.append(image);

            //}
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enableGeotag = false;

            _this.fieldMenu.enableBackup = false;

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = true;

            _this.fieldMenu.hideImageDate = false;

            _this.fieldMenu.hideImageTime = false;

            _this.fieldMenu.enableCompute = false;
			
			   _this.fieldMenu.enableColumnize = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

//            /*
//             * creates minimum photos...
//             */
//            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');
//
//            var inputContainer = $('<div/>');
//
//            var inputMin = $('<input/>', {
//                type: 'range',
//                min: 0,
//                max: 20,
//                value: _this.settings.min
//            }).on('change', function() {
//                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));
//
//                _this.input.attr('data-min', this.value);
//
//            });
//
//            inputMin.on('mousemove', function() {
//                $(inputMin).siblings('span').html(this.value);
//
//            });
//
//            // make the change immediately to take effect on the form field...
//            inputMin.change();
//
//            inputContainer.append(inputMin);
//
//            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));
//
//            fieldMenu.append(inputContainer);
//
//            /*
//             * creates maximum photos...
//             */
//            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');
//
//            inputContainer = $('<div/>');
//
//            var inputMax = $('<input/>', {
//                type: 'range',
//                min: 1,
//                max: 20,
//                value: _this.settings.max
//            }).on('change', function() {
//                _this.input.attr('data-max', this.value);
//
//            });
//
//            inputMax.on('mousemove', function() {
//                $(inputMax).siblings('span').html(this.value);
//
//            });
//
//            // make the change immediately to take effect on the form field...
//            inputMax.change();
//
//            inputContainer.append(inputMax);
//
//            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));
//
//            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

            //*added new buttons for adding/replacing/deleting image for this field.
            addEditDeleteButton(_this, fieldMenu, _this.role);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Signature = function(options) {
    var _this = {
        role: 'signature',
        fieldMenuTitle: 'Signature',
        settings: {
            value: '',
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

//            var container = $('<div/>', {
//                class: _this.role
//            });

            var container = $('<div/>', {
                class: _this.role
            }).on('click', function() {
                _this.drawingPad(this);

            });

            container.append(_this.settings.value);

            if (_this.settings.value.length === 0)
            {
                // a mobile requirement that sets to use input type image...
                var image = $('<img/>', {
                    src: 'img/form_signature.png'
                });

                container.append(image);

            }
            if (container.children().eq(0).attr('src') === '../img/form_signature.png')
            {
                container.children().eq(0).attr('src', 'img/form_signature.png');
            }

            if (container.children().eq(0).attr('src') === 'img/signature.png')
                // as mobile side will change the default img link to this, we need to change back if user does not sign.
                {
                    container.children().eq(0).attr('src', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADqSURBVHhe7dExAQAgDMCwgX/PwIGHPM1TAV3nmTD7N0gDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsANXMBDdQEvO4ujh0AAAAASUVORK5CYIITAA+Az5TyBuApAHBKXgG4DjxHyhcACv0W8OzcqSASrKARsIL+iOR+2thyASIUdgt6/7Ho/Wt8V8gFmQCA/AvjkbxH2tcABWkHo7Xo+9YuptO+uwv8FngGALgvD+onbFgHUlU0ko0FHwXu57meb4NXgm8Dr82D6gkpVr1wNLS9ZHAbRP/elXQp7+al10epXPR7t6UeADxTDwCeyWgFtf0HKE5fR//elXQnvmvN03xgWoh9BXy+lPfoWAX+RB6soWIAuAGzCdxbkm12kb27DoiW+5i6pHMHADdi1oHfJ+U5AkKBT0Dv/6Xvyrggkwp6HDzGd8ViaDN4OAD4n++KuCATAHR0XSblOwLuhfqZmgf1Q+oAABp3OSyNm6U8d8ToD7oKdfxuLgEgAYTT8Vgq5TsCxkP9LPddEVdkWgfUYAT8WewjYCt4vexplbiszwjwIEPdWB5HwKEAYJ0vgWXR4D0IAOwPADaK3QP6IFTAeRRGBgsxgs7Qk4+JGQB6RQ8EAP/xLThXZFJB1Xi8JkEvNNHvwB/OYhGkRgDV3+mWV7aAR6Ds//oRl3syjYAq9ET63mst3zShx9ZgEtzlujIKwBPgj4h5BHBkjgIA73iVmkOy7YjFrQW2AoDBGQLwewk2gUwAUPdzDnBeti8yqaAwMuIsyzfUv0MghBbXldGy/yABACZazf/LNQA6AhZJMBGaiJviwzECtrmuTASAI8U8Av4KrukOADA6bprlm+0A4CAAsNV1ZRSA34A/KGYANkgwB+QXABXCD8DTLd/sAI+EEP7pujJa9mPgUyyvbNKyc20FcQQ0IvkpyzctOgL+5boyCsASCeYf0wh4Azws7+HpBOAnSF5g+eYtnQOaXVdGAfiRBOrPthIeCgA2+xWbO7KpoLjF0L8lsIK2u65MXV1doaqqah6SV4nZF0UQjkDZf/InMrdkGwHPIPkhyzebMAKGZrEOqK2tJQCzUP58MfuiWOY5AOAhr1JzSLaVcBOSB1m+eREA1GflDkb5k1D+T8UOwCyUf2tu3dEQwAAI4FUJ4kJNtAICGJchAEehfK6GTQC0RUaj/Nm5BQBzQA0e1LHVlm/uAE/PKiIB5TMqmx2gr+WVFeBxeYiIIJlGwEQ9pGfrgXPRA2/IcATwkOBLSI6ylE9f1BCUnwuHnO2AxjViB4BnsxZnVSE1AnhIcJKlfAZmHQ4A1voTmzsyAfAo+FTL+5wED8lyR0rrcDX462I3RakC7/AiMcdkCsxaD36PmBdCm0sxQbU3lxxaju9OxncrTHVUuht5TsvDRFwMAF0AS6T9VEyU2NjFaPjkpIZrLz4M/FlwPZhui/vBi9I40gDAQABAx5vtlP5rqMfBqEfF+4R2N06F1ih2HxCFfjkEeGtSpsiLR5xoy/ePlMHvqds/iTx2JnzPbx4Bf9TyCkEci3we9y3ArtJuANDr9kWvWy/2XsdItA+g0U1xGSKf/sjnL0gOLiojvGrgUuRxe0IeVF2zkbxR7MYAfUafrnRztBBpMNXFd4qEFiUujk5IUiHI60zk9WBMPsugPs5KocZohtIcrRKzOqRPigaBc6/s3qSCNnYfCbb73m95jw3+AvjmpB6HvKjCGsUe2PU8+LgU+YSbM8fH1Ola8LxKHgUFbSh7/7fFPtwZj8PN8FeTMsQIOAYj4FnpOJGHQroLI+CilBM5Y1S/F1Ov1yVQi1t8C7KzRAAOxPMF8HvFbne/o4K4Bo3dEZehqrOHJVhLRM8Ykwjkicjj+TSVQ90OwIMLrn0t9SLdA0AvrFSTlADcK+lOxLTd1QOeAgHG7ger4LipE7ViqKt57viBNCpDRwDN4rskWJfYiHPSFyWFeixHIgDcWOkT/jvm3bBxL4PPTmEN1euVB1X6Lc3XmWmEpKNoFpLfBPdKUS+Oynrk/YpvgZZKBIDm3lwJelkorKQG/12CKOWXbC9BiHUKQLV+833wrCQA1BlHwV8h5gWhqT5ckB2NvF/2LdBSKZyE6YLghPc58P4pGk3ihDzW1mjkOxIP9sgQ1EQA8A1HIq8jmJqyDlQ/3D6l72hNRaqgMKHDnmfDbpBgNRz2XNvETKJT7lQ0fEPxC8hvJPJbKylHAN7fR+ORJktyz2/zS0mwO1bRF3fYzgmfC2H8UNqtDxsI/PtKvTypuSif1ADg3T4ajTcpprywTNLTtHzwzd8qsddHKe62lEMkcKAdLsm9kWbnxOjBubQqCO9xkqWlc4Ekqx2awwvAVyaZw5VCSbelDEIvIwijY94PfTzz0Su/FKqDohFAXU0ArogCoAEA/PsMsaudcKRR4FyN31LpvT5KiROduoZ/IQEItmNL4WJtCkBYQhAMANwkwUKuTXg6yr4sgQUWJ3wSTeVpyPv+Stb3Jkp1EE83arhTdlzCq3QJHA8hrzeoIJqWcwiACv8iCWJQqxPypNNtCnh5nnp+SKlPQqJHD0GPflLaHXa2HksfPfcDhoPplg5HAF3Lc/S9k8A86f4uiVc7FD4vkn0yj8IXKQEAEnoud7eelnjXAAV1JZguaQIQHQH0XjLgi5F3gyWeeACErojcCp9UKgA8yH0eRgIv9KsWe+/l5XoTJbgElhd/hHMALwT/FfgYiTc16bSbjLKW5U3nF1PJh7F1wfYtJGeK3U3ctj4A10n7OoAAMOjqEolfaO3Ud+7Oc88PqVOn4XUD5ykJenJaot/oMEleU1T8Jksp1OnrCNTZxo2Xvinyid77Y/t/8p1QO9Pzrnai1BUAqIrohw8DqLpytwQFzu3H07I4fVnO1KULOaCKaEbSojm6i/X4hwQb/ht9C2RvU5dvRMFIGK0Hu3t34vNwBX0GVM+K7qR6QnIBAFXRQgl+b6bUPGmezoPw53ZH4ZOc3AkEVcRFFa2cgSV+ylijk6B63vYtCF/kBIBOTMjs7XSw8daVlb6F4JOc3YqFUTBAguCuEZJs65O/BtXz1e6qekJyCQDzulSC6IekfOkjOrI7q56QnN4LB1XUF6qIo+DgmNecHDWNnj2Q4KblMN1aSdfduwaAguAdEwti8n8UwjmjM+eMNf9hSJ4IPlYC18ZQ8AB9hQLndTrcsGfAAA0D3r7yAsrcXo6AOL8ZURdnVDHDDf9NRxutnt+WkB/ryHMGU5W5KZQmkIwUCpxRedzL4OET7u69US6+JucARKLa5sueFhEbzND0CWl7IvLqp2Hz3F84IJJf9PswXSVmn1P0fmoyL/r4OZhRH8/5vvomk7tB9azvmojQSGzo+DQrXgWR98Zxy/LQiAAZAdekeTMwrFn/zlHHmCZaYFRLXJdEzxVEO0EUjF+Db0SdHs7i6oWYtu2eo7ICgDqaEWsDihrfiIJnxDVWK8iwRG7e0L3BzZ0l3JDH8xn837bW9pnXdCVmL6SHID1Gfw2Kl45EF4jFYLAuz4Fvwjes806Xc0Xk9xg4V1EuR4CHadtuy2IOYM97UYKeW0xsLOOHlsZ8e70Et6XwQiie2OFRpObO6GydP7h3MUECV8nJYvdZMf8mLY9BYm1nIbpQbpUKm79Ke44EhxWjI5L5NmcxB9TqtZe2k5YL0dM+U9zLIqtp/oAEfUvX4T1nP+CsPbFBz54xyqKPpX5htDXVEyftR1APWlRt5q0JEN2qZZKBxQ0SBBIwyq8mInDT76JtzGIE0Dzk5a627Ur+DO0lhgg5niVolKCnZhaCor2TgrlWgYgLi2EdaLlxZNBy4x0aBON1FSBB5DzHdQ8Ff4IE6sV0ri3Mj/MWweWvgCzKYgRwMcbw9f2kozVCugzCXVj0TT+NwJuJnrR2b9jrOuK4pcrgsNMkUE22nTuT1VWwvG+aYxiy+RDa1ojncpS7I7NJWBsWnu2KDj0yF0RjUHBL0TcMAh6Iv28ouUAH9cWDV+QwyICqg2uONOck4ihsL9cf3GZdgPzXmUZ1VlYQ8+W9b7z0g4FcFDh7+OfL9UCd1pmmLIOEPy7BStsWemOj8F47qmCqWh7/ejNOnWb6GwE6GvqjB9B+d2reZVxnmrQ0G8fpeoRgcI3BG+XDuS1UL5yweWaOLg/uDC7FtxvStrUcf6ShrChi4XCeGoQ0J93eChJDJ7fo2mRXZzpYDwCeqQcAz9QDgGfqAcAz/R/bNw4bMjPi/wAAAABJRU5ErkJggg==');

                    // change back to blank img
                }
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        },
        drawingPad: function(imgDiv) {
            
            var imgSource = $(imgDiv).children().eq(0).attr('src');
            
//            if(imgSource !== 'img/form_signature.png' && imgSource !== '../img/form_signature.png')
//            {
//                return;
//            }
            
            $('#canvas-container').remove();
            
            $('body').css('overflow', 'hidden');
            
            $('body').scrollTop(0);
            
            $('body').scrollLeft(0);
            
            var canvasContainer = document.createElement('div');
            
            canvasContainer.setAttribute('id', 'canvas-container');
            
            document.getElementById('main').appendChild(canvasContainer);
            
            var canvas = document.createElement('canvas');
            
            canvas.setAttribute('id', 'signature-canvas');
            
            canvasContainer.appendChild(canvas);
            
            var ctx = canvas.getContext('2d');
            
            var sketch = document.getElementById('canvas-container');
            
            var sketch_style = getComputedStyle(sketch);
            
            canvas.width = 400;
            
            canvas.height = 400;

            var colourBtns = document.createElement('div');
            colourBtns.setAttribute('class', 'pad-btn-container');
            colourBtns.innerHTML = 'Colours : ';

            var black = document.createElement('button');
            black.setAttribute('class', 'button');
            black.style.color = 'black';
            black.innerHTML = 'Black';
            black.addEventListener('click', function(){
                ctx.strokeStyle = 'black';
            }, false);
            
            var blue = document.createElement('button');
            blue.setAttribute('class', 'button');
            blue.style.color = 'blue';
            blue.innerHTML = 'Blue';
            blue.addEventListener('click', function(){
                ctx.strokeStyle = 'blue';
            }, false);
            
            var red = document.createElement('button');
            red.setAttribute('class', 'button');
            red.style.color = 'red';
            red.innerHTML = 'Red';
            red.addEventListener('click', function(){
                ctx.strokeStyle = 'red';
            }, false);
            
            colourBtns.appendChild(black);
            
            colourBtns.appendChild(blue);
            
            colourBtns.appendChild(red);
            
            canvasContainer.appendChild(colourBtns);
            
            var brushBtns = document.createElement('div');
            brushBtns.setAttribute('class', 'pad-btn-container');
            brushBtns.innerHTML = 'Brush Size : ';
            
            var small = document.createElement('button');
            small.setAttribute('class', 'button');
            small.innerHTML = 'Small';
            small.addEventListener('click', function(){
                ctx.lineWidth = 2;
            }, false);
            
            var medium = document.createElement('button');
            medium.setAttribute('class', 'button');
            medium.innerHTML = 'Medium';
            medium.addEventListener('click', function(){
                ctx.lineWidth = 5;
            }, false);
            
            var large = document.createElement('button');
            large.setAttribute('class', 'button');
            large.innerHTML = 'Large';
            large.addEventListener('click', function(){
                ctx.lineWidth = 10;
            }, false);
            
            var xLarge = document.createElement('button');
            xLarge.setAttribute('class', 'button');
            xLarge.innerHTML = 'X-Large';
            xLarge.addEventListener('click', function(){
                ctx.lineWidth = 20;
            }, false);
            
            brushBtns.appendChild(small);
            
            brushBtns.appendChild(medium);
            
            brushBtns.appendChild(large);
            
            brushBtns.appendChild(xLarge);
            
            canvasContainer.appendChild(brushBtns);
            
            var actionBtns = document.createElement('div');
            actionBtns.setAttribute('class', 'pad-btn-container');
            actionBtns.style.textAlign = 'center';
            
            var eraser = document.createElement('button');
            eraser.setAttribute('class', 'button');
            eraser.innerHTML = 'Eraser';
            eraser.addEventListener('click', function(){
                ctx.strokeStyle = '#ffffff';
            }, false);
            
            var saveSignature = document.createElement('button');
            saveSignature.setAttribute('class', 'button primary');
            saveSignature.innerHTML = 'Save';
            saveSignature.addEventListener('click', function(){
                var image = canvas.toDataURL("image/png");
                
                $(imgDiv).children().eq(0).attr('src', image);
                
                $('body').css('overflow', 'auto');
                
                var container = $('#canvas-container');
                
                container.hide();
                
                ctx.clearRect(0, 0, canvas.width,canvas.height);
                
            }, false);
            
            var clear = document.createElement('button');
            clear.setAttribute('class', 'button');
            clear.innerHTML = 'Clear';
            clear.addEventListener('click', function(){
                ctx.clearRect(0, 0, canvas.width,canvas.height);
            }, false);
            
            var cancel = document.createElement('button');
            cancel.setAttribute('class', 'button');
            cancel.innerHTML = 'Cancel';
            cancel.addEventListener('click', function(e){
                
                $('body').css('overflow', 'auto');
                
                var container = $('#canvas-container');
                
                ctx.clearRect(0, 0, canvas.width,canvas.height);
                
                container.hide();
                
            }, false);
            
            actionBtns.appendChild(eraser);
            
            actionBtns.appendChild(saveSignature);
            
            actionBtns.appendChild(clear);
            
            actionBtns.appendChild(cancel);
            
            canvasContainer.appendChild(actionBtns);
            
            var mouse = {x: 0, y: 0};
            
            canvas.addEventListener('mousemove', function(e) {
                mouse.x = ( e.pageX - this.offsetLeft ) + $('#canvas-container').scrollLeft();
                mouse.y = ( e.pageY - this.offsetTop ) + $('#canvas-container').scrollTop();
            }, false);
            
            ctx.lineJoin = 'round';
            ctx.lineCap = 'round';
            ctx.strokeStyle = 'black';

            canvas.addEventListener('mousedown', function(e) {
                ctx.beginPath();
                ctx.moveTo(mouse.x, mouse.y);
                canvas.addEventListener('mousemove', onPaint, false);
            }, false);

            canvas.addEventListener('mouseup', function() {
                canvas.removeEventListener('mousemove', onPaint, false);
            }, false);

            var onPaint = function() {
                ctx.lineTo(mouse.x, mouse.y);
                ctx.stroke();
            };
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Barcode = function(options) {
    var _this = {
        role: 'barcode',
        fieldMenuTitle: 'Barcode',
        settings: {
            value: '',
            items: [],
            min: 0,
            max: 5,
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role,
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            // a mobile requirement that sets to use input type image...
            var image = $('<input/>', {
                type: 'image',
                src: 'img/form_barcode.png'
            }).on('click', function() {
                return false;
            });

            var dataBarcodeString = "";

            var ul = $('<ul/>', {
                'data-barcode': ''
            });

            if (_this.settings.items.length > 0)
            {
                for (var i = 0; i < _this.settings.items.length; i++)
                {
                    ul.append("<li>" + _this.settings.items[i] + "</li>");

                    if (dataBarcodeString != "")
                    {
                        dataBarcodeString = dataBarcodeString + ",";

                    }
                    dataBarcodeString = dataBarcodeString + _this.settings.items[i];

                }
            }
            ul.attr('data-barcode', dataBarcodeString);

            _this.input = container;

            var barcodeLabel = $('<label/>');

            var inputText = $('<input/>', {
                type: 'text'
            });

            barcodeLabel.append(_this.settings.value);

            container.append(barcodeLabel);

            container.append(ul);

            container.append(inputText);

            container.append(image);

            field.append(container);

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableCompute = false;
			
			   _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var inputContainer = $('<div/>');

            var inputMin = $('<input/>', {
                type: 'range',
                min: 0,
                max: 10,
                value: _this.settings.min
            }).on('change', function() {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));

                _this.input.attr('data-min', this.value);

            });

            inputMin.on('mousemove', function() {
                $(inputMin).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMin.change();

            inputContainer.append(inputMin);

            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));

            fieldMenu.append(inputContainer);

            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            inputContainer = $('<div/>');

            var inputMax = $('<input/>', {
                type: 'range',
                min: 1,
                max: 10,
                value: _this.settings.max
            }).on('change', function() {
                _this.input.attr('data-max', this.value);

            });

            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMax.change();

            inputContainer.append(inputMax);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};
var Ratings = function(options) {
    var _this = {
        role: 'ratings',
        fieldMenuTitle: 'Ratings',
        settings: {
            max: 4,
            items: [],
            selections: [],
            hint: null
        },
        create: function(field) {
            var container = $('<div/>', {class: _this.role, 'data-max': _this.settings.max});
            var fieldset = $('<fieldset/>');    // special request from mobile side...
            var ratingLabel = $('<div/>', {class: 'rating'});
            _this.input = container;
            if (_this.settings.items.length === 0)
            {
                _this.settings.items.push(_this.form.options.language.formEditorTitle);

            }
            var i = 1;
            for (var j = -1; j <= _this.settings.max; j++)
            {
                var ratingItem = $('<div/>');
                if (j === -1)
                {
                    ratingItem.append($('<label/>', {class: 'rating-star'}).html('NA'));

                }
                else
                {
                    ratingItem.append($('<label/>', {class: 'rating-star'}).html(j));

                }
                var modifiedVal;
                if (j === -1) // is NA
                {
                    modifiedVal = 0;

                }
                else if (j === 0) // is 0
                {
                    modifiedVal = 0.1;

                }
                else
                {
                    modifiedVal = j;

                }
                ratingItem.append($('<input/>', {type: 'radio', class: 'rating-input', id: 'rating-input-' + _this.id + '-' + i + '-' + j, name: 'rating-input-' + _this.id + '-' + i, value: modifiedVal}));
                ratingLabel.append(ratingItem);

            }

            fieldset.append(ratingLabel);
            container.append(fieldset);
            field.append(container);
            _this.fieldMenu.enablePreview = false;
            _this.fieldMenu.enableCompute = false;
			 _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);
            var field = $(parent.selector);
            var toolbar = $(fieldMenu).find('.toolbar');
            var max = _this.input.attr('data-max');
            /*
             * creates maximum ratings...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');
            var inputContainer = $('<div/>');
            var inputRatings;
            var inputMax = $('<input/>', {type: 'range', min: 0, max: 11, value: _this.settings.max}).on('change', function() {
                max = this.value;
                _this.input.attr('data-max', max);
                inputRatings.change();

            });
            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });
            inputContainer.append(inputMax);
            inputContainer.append($('<span/>').html(max));
            fieldMenu.append(inputContainer);
            /*
             * creates textarea for ratings input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorItems + '</label>');
            inputContainer = $('<div/>', {class: 'input-control textarea full-size'});
            inputRatings = $('<textarea/>', {rows: 5}).on('change', function() {
                var container = _this.input;
                var fieldset = $('<fieldset/>');    // special request from mobile side...
                var hintVal = $(field.selector + '-hint').html();   // remember the hint before it is gone after the below code...
                container.html('');
                var lines = this.value.split('\n');
                for (var i = 0; i < lines.length; i++)
                {
                    var value = lines[i];
                    var ratingLabel = $('<div/>', {class: 'rating'});
                    ratingLabel.append($('<label/>').html(value));
                    if (i === 0)    // only applicable to the first rating...
                    {
                        var hint = $('<label/>', {id: _this.selector.substring(1) + '-hint', class: 'hint-label', style: 'display:none'}).html(hintVal);
                        var buttonHint = $('<button/>', {type: 'button', id: _this.selector.substring(1) + '-buttonHint', class: 'hint-button', style: 'display:none'}).html('');
                        ratingLabel.append(buttonHint);
                        buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');
                        if (hintVal && hintVal.length > 0)
                        {
                            buttonHint.css('display', 'block');

                        }
                        ratingLabel.append(hint);

                    }
                    for (var j = -1; j <= max; j++)
                    {
                        var ratingItem = $('<div/>');
                        if (j === -1)
                        {
                            ratingItem.append($('<label/>', {class: 'rating-star'}).html('NA'));

                        }
                        else
                        {
                            ratingItem.append($('<label/>', {class: 'rating-star'}).html(j));

                        }
                        var modifiedVal;
                        if (j === -1) // is NA
                        {
                            modifiedVal = 0;

                        }
                        else if (j === 0) // is 0
                        {
                            modifiedVal = 0.1;

                        }
                        else
                        {
                            modifiedVal = j;

                        }
                        ratingItem.append($('<input/>', {type: 'radio', class: 'rating-input', id: 'rating-input-' + _this.id + '-' + (i + 1) + '-' + j, name: 'rating-input-' + _this.id + '-' + (i + 1), value: modifiedVal}));
                        ratingLabel.append(ratingItem);

                    }
                    fieldset.append(ratingLabel);

                }
                container.append(fieldset);
                field.append(container);

            });
            // preset values to ratings...
            inputRatings.val(_this.settings.items.join('\n'));
            // make the change immediately to take effect on the form field...
            //inputRatings.change();
            // make the change immediately to take effect on the form field. inside the inputMax change will also call the inputRatings change...
            inputMax.change();
            // set selections for all the ratings...
            for (var j = 0; j < _this.settings.selections.length; j++)
            {
                var index = _this.settings.selections[j];
                var input = $('#rating-input-' + _this.id + '-' + (j + 1) + '-' + (index - 1));
                input.attr('checked', true);

            }
            inputRatings.append('untitled');
            inputContainer.append(inputRatings);
            fieldMenu.append(inputContainer);
            var hintContainer = $('<div/>', {class: 'input-control textarea full-size'});
            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');
            var hintBox = $('<textarea/>', {rows: 5}).on('change', function() {
                $(field.selector + '-hint').html(this.value);
                var value = this.value;
                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });
            hintBox.html(_this.settings.hint);
            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);
            var buttonClearDefault = $('<button/>', {type: 'button', class: 'toolbar-button', title: _this.form.options.language.formEditorToolbarClearDefault}).html('<span class="mif-cross"></span>').on('click', function() {
                var inputs = field.find('.ratings :input');
                inputs.removeAttr('checked');

            });
            var toolbarSection = $('<div/>', {class: 'toolbar-section'}).append(buttonClearDefault);
            toolbar.append(toolbarSection);
        },
        setText: function(container) {
            var text = '';
            $(container).children().each(function() {
                if (text.length > 0)
                {
                    text += '\n';

                }
                text += $(this).val();

            });
            return text;
        }
    };
    _this = $.extend(new FormField(), _this, options);
    return _this;
};
var Collapser = function(options) {
    var _this = {
        role: 'collapser',
        fieldMenuTitle: 'Collapser',
        settings: {
            text: '',
            max: 0,
            hint: null
        },
        input: null,
        create: function(field) {
            field.attr('data-max', _this.settings.max);

            field.attr('onclick', 'toggleCollapser(\'' + _this.selector.substring(1) + '\', ' + _this.settings.max + ');');

            $(field).children(':first').addClass('collapser expand');

            _this.input = field;

            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableCompute = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates collapsable fields counter...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorCollapsedItems + '</label>');

            var inputContainer = $('<div/>');

            var inputCount = $('<input/>', {
                type: 'range',
                min: 0,
                max: 150,
                value: _this.settings.max
            }).on('change', function() {
                _this.input.nextAll().css('display', 'block');

                _this.input.attr('data-max', this.value);

                _this.input.attr('onclick', 'toggleCollapser(\'' + _this.selector.substring(1) + '\', ' + this.value + ');');

                _this.input.children(':first').addClass('expand');

            });

            inputCount.on('mousemove', function() {
                $(inputCount).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputCount.change();

            inputContainer.append(inputCount);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var RatingsSummary = function(options) {
    var _this = {
        role: 'ratingsSummary',
        fieldMenuTitle: 'Ratings Summary',
        settings: {
            value: '',
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });
            var ratingsSum = $('<button/>', {
                type: 'button',
                id: 'ratingsSum',
                style: 'width:auto; height:auto;'
            }).html(_this.form.menu.options.language.formEditorShow).on('click', function() {});

            container.append(ratingsSum);

            _this.input = container;

            field.append(container);

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableCompute = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var Email = function(options) {
    var _this = {
        create: function(field) {
            _this.input = $('<input/>', {
                type: 'email',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			
			 _this.fieldMenu.enableColumnize = true;

        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'email';

    _this.fieldMenuTitle = 'Email';

    return _this;
};

var EmailMultiple = function(options) {
    var _this = {
        create: function(field) {
		 _this.fieldMenu.enableColumnize = true;
                }
    };

    _this = $.extend(new Checkboxes(), _this, options);

    _this.role = 'email-multiple';

    _this.fieldMenuTitle = 'Email Multiple';

    return _this;
};

var EmailSelection = function(options) {
    var _this = {};

    _this = $.extend(new Selection(), _this, options);

    _this.role = 'email-selection';

    _this.fieldMenuTitle = 'Email Selection';

    return _this;
};

var Drawing = function(options) {
    var _this = {
        role: 'drawing',
        fieldMenuTitle: 'Drawing',
        settings: {
            value: '',
            hint: null
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role
            });

            container.append(_this.settings.value);

            if (_this.settings.value.length === 0)
            {
                // a mobile requirement that sets to use input type image...
                var image = $('<img/>', {
                    src: 'img/form_signature.png'
                }).on('click', function() {
                    return false;
                });

                container.append(image);

            }
            if (container.children().eq(0).attr('src') === '../img/form_signature.png')
            {
                container.children().eq(0).attr('src', 'img/form_signature.png');
            }
            if (container.children().eq(0).attr('src') === 'img/signature.png') // as mobile side will change the default img link to this, we need to change back if user does not sign.
            {
                container.children().eq(0).attr('src', 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADqSURBVHhe7dExAQAgDMCwgX/PwIGHPM1TAV3nmTD7N0gDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsA1gCsAVgDsAZgDcAagDUAawDWAKwBWAOwBmANwBqANQBrANYArAFYA7AGYA3AGoA1AGsANXMBDdQEvO4ujh0AAAAASUVORK5CYIITAA+Az5TyBuApAHBKXgG4DjxHyhcACv0W8OzcqSASrKARsIL+iOR+2thyASIUdgt6/7Ho/Wt8V8gFmQCA/AvjkbxH2tcABWkHo7Xo+9YuptO+uwv8FngGALgvD+onbFgHUlU0ko0FHwXu57meb4NXgm8Dr82D6gkpVr1wNLS9ZHAbRP/elXQp7+al10epXPR7t6UeADxTDwCeyWgFtf0HKE5fR//elXQnvmvN03xgWoh9BXy+lPfoWAX+RB6soWIAuAGzCdxbkm12kb27DoiW+5i6pHMHADdi1oHfJ+U5AkKBT0Dv/6Xvyrggkwp6HDzGd8ViaDN4OAD4n++KuCATAHR0XSblOwLuhfqZmgf1Q+oAABp3OSyNm6U8d8ToD7oKdfxuLgEgAYTT8Vgq5TsCxkP9LPddEVdkWgfUYAT8WewjYCt4vexplbiszwjwIEPdWB5HwKEAYJ0vgWXR4D0IAOwPADaK3QP6IFTAeRRGBgsxgs7Qk4+JGQB6RQ8EAP/xLThXZFJB1Xi8JkEvNNHvwB/OYhGkRgDV3+mWV7aAR6Ds//oRl3syjYAq9ET63mst3zShx9ZgEtzlujIKwBPgj4h5BHBkjgIA73iVmkOy7YjFrQW2AoDBGQLwewk2gUwAUPdzDnBeti8yqaAwMuIsyzfUv0MghBbXldGy/yABACZazf/LNQA6AhZJMBGaiJviwzECtrmuTASAI8U8Av4KrukOADA6bprlm+0A4CAAsNV1ZRSA34A/KGYANkgwB+QXABXCD8DTLd/sAI+EEP7pujJa9mPgUyyvbNKyc20FcQQ0IvkpyzctOgL+5boyCsASCeYf0wh4Azws7+HpBOAnSF5g+eYtnQOaXVdGAfiRBOrPthIeCgA2+xWbO7KpoLjF0L8lsIK2u65MXV1doaqqah6SV4nZF0UQjkDZf/InMrdkGwHPIPkhyzebMAKGZrEOqK2tJQCzUP58MfuiWOY5AOAhr1JzSLaVcBOSB1m+eREA1GflDkb5k1D+T8UOwCyUf2tu3dEQwAAI4FUJ4kJNtAICGJchAEehfK6GTQC0RUaj/Nm5BQBzQA0e1LHVlm/uAE/PKiIB5TMqmx2gr+WVFeBxeYiIIJlGwEQ9pGfrgXPRA2/IcATwkOBLSI6ylE9f1BCUnwuHnO2AxjViB4BnsxZnVSE1AnhIcJKlfAZmHQ4A1voTmzsyAfAo+FTL+5wED8lyR0rrcDX462I3RakC7/AiMcdkCsxaD36PmBdCm0sxQbU3lxxaju9OxncrTHVUuht5TsvDRFwMAF0AS6T9VEyU2NjFaPjkpIZrLz4M/FlwPZhui/vBi9I40gDAQABAx5vtlP5rqMfBqEfF+4R2N06F1ih2HxCFfjkEeGtSpsiLR5xoy/ePlMHvqds/iTx2JnzPbx4Bf9TyCkEci3we9y3ArtJuANDr9kWvWy/2XsdItA+g0U1xGSKf/sjnL0gOLiojvGrgUuRxe0IeVF2zkbxR7MYAfUafrnRztBBpMNXFd4qEFiUujk5IUiHI60zk9WBMPsugPs5KocZohtIcrRKzOqRPigaBc6/s3qSCNnYfCbb73m95jw3+AvjmpB6HvKjCGsUe2PU8+LgU+YSbM8fH1Ola8LxKHgUFbSh7/7fFPtwZj8PN8FeTMsQIOAYj4FnpOJGHQroLI+CilBM5Y1S/F1Ov1yVQi1t8C7KzRAAOxPMF8HvFbne/o4K4Bo3dEZehqrOHJVhLRM8Ykwjkicjj+TSVQ90OwIMLrn0t9SLdA0AvrFSTlADcK+lOxLTd1QOeAgHG7ger4LipE7ViqKt57viBNCpDRwDN4rskWJfYiHPSFyWFeixHIgDcWOkT/jvm3bBxL4PPTmEN1euVB1X6Lc3XmWmEpKNoFpLfBPdKUS+Oynrk/YpvgZZKBIDm3lwJelkorKQG/12CKOWXbC9BiHUKQLV+833wrCQA1BlHwV8h5gWhqT5ckB2NvF/2LdBSKZyE6YLghPc58P4pGk3ihDzW1mjkOxIP9sgQ1EQA8A1HIq8jmJqyDlQ/3D6l72hNRaqgMKHDnmfDbpBgNRz2XNvETKJT7lQ0fEPxC8hvJPJbKylHAN7fR+ORJktyz2/zS0mwO1bRF3fYzgmfC2H8UNqtDxsI/PtKvTypuSif1ADg3T4ajTcpprywTNLTtHzwzd8qsddHKe62lEMkcKAdLsm9kWbnxOjBubQqCO9xkqWlc4Ekqx2awwvAVyaZw5VCSbelDEIvIwijY94PfTzz0Su/FKqDohFAXU0ArogCoAEA/PsMsaudcKRR4FyN31LpvT5KiROduoZ/IQEItmNL4WJtCkBYQhAMANwkwUKuTXg6yr4sgQUWJ3wSTeVpyPv+Stb3Jkp1EE83arhTdlzCq3QJHA8hrzeoIJqWcwiACv8iCWJQqxPypNNtCnh5nnp+SKlPQqJHD0GPflLaHXa2HksfPfcDhoPplg5HAF3Lc/S9k8A86f4uiVc7FD4vkn0yj8IXKQEAEnoud7eelnjXAAV1JZguaQIQHQH0XjLgi5F3gyWeeACErojcCp9UKgA8yH0eRgIv9KsWe+/l5XoTJbgElhd/hHMALwT/FfgYiTc16bSbjLKW5U3nF1PJh7F1wfYtJGeK3U3ctj4A10n7OoAAMOjqEolfaO3Ud+7Oc88PqVOn4XUD5ykJenJaot/oMEleU1T8Jksp1OnrCNTZxo2Xvinyid77Y/t/8p1QO9Pzrnai1BUAqIrohw8DqLpytwQFzu3H07I4fVnO1KULOaCKaEbSojm6i/X4hwQb/ht9C2RvU5dvRMFIGK0Hu3t34vNwBX0GVM+K7qR6QnIBAFXRQgl+b6bUPGmezoPw53ZH4ZOc3AkEVcRFFa2cgSV+ylijk6B63vYtCF/kBIBOTMjs7XSw8daVlb6F4JOc3YqFUTBAguCuEZJs65O/BtXz1e6qekJyCQDzulSC6IekfOkjOrI7q56QnN4LB1XUF6qIo+DgmNecHDWNnj2Q4KblMN1aSdfduwaAguAdEwti8n8UwjmjM+eMNf9hSJ4IPlYC18ZQ8AB9hQLndTrcsGfAAA0D3r7yAsrcXo6AOL8ZURdnVDHDDf9NRxutnt+WkB/ryHMGU5W5KZQmkIwUCpxRedzL4OET7u69US6+JucARKLa5sueFhEbzND0CWl7IvLqp2Hz3F84IJJf9PswXSVmn1P0fmoyL/r4OZhRH8/5vvomk7tB9azvmojQSGzo+DQrXgWR98Zxy/LQiAAZAdekeTMwrFn/zlHHmCZaYFRLXJdEzxVEO0EUjF+Db0SdHs7i6oWYtu2eo7ICgDqaEWsDihrfiIJnxDVWK8iwRG7e0L3BzZ0l3JDH8xn837bW9pnXdCVmL6SHID1Gfw2Kl45EF4jFYLAuz4Fvwjes806Xc0Xk9xg4V1EuR4CHadtuy2IOYM97UYKeW0xsLOOHlsZ8e70Et6XwQiie2OFRpObO6GydP7h3MUECV8nJYvdZMf8mLY9BYm1nIbpQbpUKm79Ke44EhxWjI5L5NmcxB9TqtZe2k5YL0dM+U9zLIqtp/oAEfUvX4T1nP+CsPbFBz54xyqKPpX5htDXVEyftR1APWlRt5q0JEN2qZZKBxQ0SBBIwyq8mInDT76JtzGIE0Dzk5a627Ur+DO0lhgg5niVolKCnZhaCor2TgrlWgYgLi2EdaLlxZNBy4x0aBON1FSBB5DzHdQ8Ff4IE6sV0ri3Mj/MWweWvgCzKYgRwMcbw9f2kozVCugzCXVj0TT+NwJuJnrR2b9jrOuK4pcrgsNMkUE22nTuT1VWwvG+aYxiy+RDa1ojncpS7I7NJWBsWnu2KDj0yF0RjUHBL0TcMAh6Iv28ouUAH9cWDV+QwyICqg2uONOck4ihsL9cf3GZdgPzXmUZ1VlYQ8+W9b7z0g4FcFDh7+OfL9UCd1pmmLIOEPy7BStsWemOj8F47qmCqWh7/ejNOnWb6GwE6GvqjB9B+d2reZVxnmrQ0G8fpeoRgcI3BG+XDuS1UL5yweWaOLg/uDC7FtxvStrUcf6ShrChi4XCeGoQ0J93eChJDJ7fo2mRXZzpYDwCeqQcAz9QDgGfqAcAz/R/bNw4bMjPi/wAAAABJRU5ErkJggg==');

                // should be change back to blank img
            }
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var NumberKeypad = function(options) {
    var _this = {
        settings: {
            value: '',
            hint: null
        },
        create: function(field) {
            _this.input = $('<input/>', {
                type: 'number',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			 _this.fieldMenu.enableColumnize = true;

        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'number-keypad';

    _this.fieldMenuTitle = 'Number Keypad';

    return _this;
};

var NumberRange = function(options) {
    var _this = {
        settings: {
            value: '',
            hint: null,
            id:'',
            placeholder: '',
            minimum: '',
            maximum: '',
        },
        create: function(field) {
            _this.input = $('<input/>', {
                type: 'number',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			 _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);
            
             fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var minContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var minLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.minimum
            }).on('change', function() {
                _this.input.attr("minimum", this.value);

            });
            // preset the value for the input text...
            minLabel.val(_this.settings.minimum);
            
            minLabel.change();

            minContainer.append(minLabel);

            fieldMenu.append(minContainer);

            fieldMenu.append(minContainer);

            field.append(_this.input);
            
            _this.fieldMenu.enableColumnize = true;
            
             fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            var maxContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var maxLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.maximum
            }).on('change', function() {
                _this.input.attr("maximum", this.value);

            });
            // preset the value for the input text...
            maxLabel.val(_this.settings.maximum);

            maxLabel.change();

            maxContainer.append(maxLabel);

            fieldMenu.append(maxContainer);          
            
            fieldMenu.append('<label>' + _this.form.options.language.formEditorPlaceholder + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var inputLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.placeholder
            }).on('change', function() {
                _this.input.attr("placeholder", this.value);

            });

            // make the change immediately to take effect on the form field...
            inputLabel.change();

            inputContainer.append(inputLabel);

            fieldMenu.append(inputContainer);
                      
            fieldMenu.append('<label>' + _this.form.options.language.formEditorCharacterLimit + '</label>');

            inputContainer = $('<div/>');

            var inputMaxLen = $('<input/>', {
                type: 'range',
                min: 0,
                max: 200,
                value: _this.settings.maxlength
            }).on('change', function() {
                _this.input.attr("maxlength", this.value);

            });

            inputMaxLen.on('mousemove', function() {
                $(inputMaxLen).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMaxLen.change();

            inputContainer.append(inputMaxLen);

            inputContainer.append($('<span/>').html(_this.input.attr('maxlength')));

            fieldMenu.append(inputContainer);
            
            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);
            
            fieldMenu.append('<label>' + _this.form.options.language.formEditorId + '</label>');

            var idContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var idLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.id,
                disabled: 'true'
            }).on('change', function() {
                _this.input.attr("id", this.value);

            });

            idLabel.change();

            idContainer.append(idLabel);

            fieldMenu.append(idContainer);
          
        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'number-range';

    _this.fieldMenuTitle = 'Number Range';

    return _this;
};

var DatePicker = function(options) {
    var _this = {
        create: function(field) {
            _this.input = $('<input/>', {
                type: 'date',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			 _this.fieldMenu.enableColumnize = true;

        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'date-picker';

    _this.fieldMenuTitle = 'Date';

    return _this;
};

var TimePicker = function(options) {
    var _this = {
        create: function(field) {
            _this.input = $('<input/>', {
                type: 'time',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			 _this.fieldMenu.enableColumnize = true;

        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'time-picker';

    _this.fieldMenuTitle = 'Time';

    return _this;
};

var DateTimePicker = function(options) {
    var _this = {
        create: function(field) {
            
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<input/>', {
                type: 'datetime-local',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });

            field.append(_this.input);
			 _this.fieldMenu.enableColumnize = true;

        }
    };

    _this = $.extend(new SingleLine(), _this, options);

    _this.role = 'date-time-picker';

    _this.fieldMenuTitle = 'Date Time';

    return _this;
};

var IconCheckbox = function(options) {
    var _this = {
        role: 'iconcheckboxes',
        fieldMenuTitle: 'Icon Checkbox',
        settings: {
            items: [],
            selections: [],
            value: '',
            min: 0,
            max: 1,
            hint: null,
            edit: ''
        },
        fileButton: '', // this variable is to identify which button was click for add&replace image function
        fileSelector: null,
        imageElement: null,
        create: function(field) {
            field.css('table-layout', 'fixed');

            field.css('display', 'inline-block');

            field.css('width', '50%');

            field.css('border', '1px solid #4D94DB');

            field.css('vertical-align', 'top');

            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            /******************************************************************************************************Image*/
            var imageContainer = $('<div/>', {
                id: 'image',
                class: "iconcheckbox",
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            imageContainer.append(_this.settings.value); //adding all the current image into the list
            _this.input = imageContainer;

            _this.fileSelector = $('<input/>', {
                type: 'file'
            }).on('change', function(e) {
                // Added the read file function here as tried to copy from staticImage to put at handlefile but failed.
                var file = e.target.files[0]; // only get first file...
                var reader = new FileReader();

                reader.onloadend = function() {
                    var url = reader.result;

                    resizeImageCamera(url, 0.5, function(url) { // Different from StaticImage Resize, this re-size all image to 400 x 300 or 300 x 400 depending if it is landscape or potrait.
                        var selectedfield = $(form).find('.form-field.selected')
                        if (selectedfield.children().length <= _this.settings.max)
                        {
                            if (_this.fileButton === '')
                            { // for add image function
                                _this.imageElement = $('<img/>', {
                                    src: _this.settings.value
                                });

                                Number.prototype.pad = function(len) {
                                    return(new Array(len + 1).join("0") + this).slice(-len);
                                };

                                var date = new Date($.now());

                                var formatDate = date.getDate().pad(2) + "/" + date.getMonth().pad(2) + "/" + date.getFullYear().toString().substr(-2) + " " + date.getHours().pad(2) + ":" + date.getMinutes().pad(2) + ":" + date.getSeconds().pad(2);

                                _this.imageElement.attr('data-timestamp', formatDate);

                                _this.imageElement.attr('data-block-unit', '0'); // This field will affect PDF
                                _this.imageElement.attr('data-block-level', '0'); //This field will affect PDF
                                _this.imageElement.attr('data-latitude', '0');

                                _this.imageElement.attr('data-longitude', '0');

                                _this.imageElement.css('background-color', 'rgb(0, 0, 0');

                                _this.imageElement.css('height', '128px');

                                _this.imageElement.css('width', '128px');

                                _this.imageElement.attr('onclick', '$(this).toggleClass(\'selected\');');

                                _this.imageElement.attr('src', url);

                                imageContainer.append(_this.imageElement);

                                if ($(_this.selector + ' div.iconcheckbox').children().hasClass('selected'))
                                {
                                    var x = 0;

                                    $(_this.selector + ' div.iconcheckbox').children().each(function() { // this code can be further improve to be a single line.
                                        if ($(this).hasClass('selected'))
                                        {
                                            x = $(this).index();

                                            return false;
                                        }
                                    });

                                    _this.imageElement.insertBefore(imageContainer.find('img').eq(x));

                                }
                                else
                                {
                                    _this.imageElement.insertBefore(imageContainer.find('input'));

                                }
                                _this.imageElement.attr('src', url);

                            }
                            else
                            {
                                $(_this.selector + ' div.iconcheckbox').children().eq(_this.fileButton).attr('src', url); // for replace image function, get the selected picture and change the src
                            }
                        }
                        else
                        {
//                            dialog('Maximum number of image added', 'alert');

                            dialog('Error retrieving data', 'alert');

                        }
                    });

                };

                if (file)
                {
                    var imageType = /image.*/;

                    if (file.type.match(imageType))
                    {
                        reader.readAsDataURL(file);

                    }
                    else
                    {
                        _this.imageElement.attr('src', '');

                    }
                }
                else
                {
                    _this.imageElement.attr('src', '');

                }
            });

            imageContainer.append(_this.settings.value); //adding all the current image into the list
            _this.input = imageContainer;

            field.append(imageContainer);

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /******************************************************************************************************Toolbar*/
            var toolbar = $(fieldMenu).find('.toolbar');

            var buttonUpload = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.form.options.language.formEditorAddImage
            }).html('<span class="mif-file-upload"></span>').on('click', function() {
                _this.fileButton = '';

                _this.fileSelector.click();

            });

            var buttonClearDefault = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.form.options.language.formEditorToolbarClearDefault
            }).html('<span class="mif-cancel"></span>').on('click', function() {
                var inputs = field.find('.iconcheckboxes :input');

                inputs.removeAttr('checked');

            });

            var buttonDelete = $('<button/>', {
                type: 'button',
                class: 'toolbar-button',
                title: _this.form.options.language.formEditorDeleteImage
            }).html('<span class="mif-cross"></span>').on('click', function() {
                // Check if there is any selected img
                if ($(_this.selector + ' div.iconcheckbox').children().hasClass('selected'))
                {
                    $(_this.selector + ' div.iconcheckbox').children().each(function() { // this code can be further improve to be a single line.
                        if ($(this).hasClass('selected'))
                        {
                            $(this).remove();

                        }
                    });

                }
                else
                {
                    dialog('No Image Selected', 'Please select a image to delete', 'alert');

                }
            });

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            }).append(buttonClearDefault);

            toolbar.append(toolbarSection);

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            }).append(buttonUpload);

            toolbar.append(toolbarSection);

            var toolbarSection = $('<div/>', {
                class: 'toolbar-section'
            }).append(buttonDelete);

            toolbar.append(toolbarSection);

            /******************************************************************************************************Hint*/
            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var AddCamera = function(options) {
    var _this = {
        role: 'addcamera',
        fieldMenuTitle: 'Dynamic Camera',
        settings: {
            value: '',
            min: 0,
            max: 5,
            maxAdd: 15
        },
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            var container = $('<div/>', {
                class: _this.role,
                'data-min': _this.settings.min,
                'data-max': _this.settings.max
            });

            // this fileSelector same as the one used in StaticImage. Help read new upload for Add and Replace Functio.
            var moreCamera2 = $('<input/>', {
                type: 'button',
                class: 'addCameraButton',
                value: _this.form.menu.options.language.formEditorAddCamera
            }).html('');

            container.append(moreCamera2);

            container.append(_this.settings.value); //adding all the current image into the list
            _this.input = container;

            field.append(container);

            _this.fieldMenu.enableGeotag = true;

            _this.fieldMenu.enableBackup = true;

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.hideImageDate = true;

            _this.fieldMenu.hideImageTime = true;

            _this.fieldMenu.enableCompute = false;
			
			 _this.fieldMenu.enableColumnize = true;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');

            var inputContainer = $('<div/>');

            var inputMin = $('<input/>', {
                type: 'range',
                min: 0,
                max: 10,
                value: _this.settings.min
            }).on('change', function() {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));

                _this.input.attr('data-min', this.value);

            });

            inputMin.on('mousemove', function() {
                $(inputMin).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMin.change();

            inputContainer.append(inputMin);

            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));

            fieldMenu.append(inputContainer);

            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');

            inputContainer = $('<div/>');

            var inputMax = $('<input/>', {
                type: 'range',
                min: 1,
                max: 10,
                value: _this.settings.max
            }).on('change', function() {
                _this.input.attr('data-max', this.value);

            });

            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMax.change();

            inputContainer.append(inputMax);

            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));

            fieldMenu.append(inputContainer);

            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximumAdd + '</label>');

            inputContainer = $('<div/>');

            var inputMaxAdd = $('<input/>', {
                type: 'range',
                min: 0,
                max: 15,
                value: _this.settings.maxAdd
            }).on('change', function() {
                _this.input.attr('data-maxAdd', this.value);

            });

            inputMaxAdd.on('mousemove', function() {
                $(inputMaxAdd).siblings('span').html(this.value);

            });

            // make the change immediately to take effect on the form field...
            inputMaxAdd.change();

            inputContainer.append(inputMaxAdd);

            inputContainer.append($('<span/>').html(_this.input.attr('data-maxAdd')));

            fieldMenu.append(inputContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

var CameraLibrary = function(options) {
    var _this = {
        role: 'cameralibrary',
        fieldMenuTitle: 'Camera Library',
        settings: {
            value: '',
            min: 0,
            max: 5,
            hint: null,
            edit: ''
        },
        fileButton: '', // this variable is to identify which button was click for add or replace, if replace then will store the index.
        fileSelector: null,
        imageElement: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html();   // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {id: _this.selector.substring(1) + '-hint', class: 'hint-label', style: 'display:none'}).html(hintVal);
            var buttonHint = $('<button/>', {type: 'button', id: _this.selector.substring(1) + '-buttonHint', class: 'hint-button', style: 'display:none'}).html('');
            field.append(buttonHint);
            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');
            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);
            var container = $('<div/>', {class: _this.role, 'data-min': _this.settings.min, 'data-max': _this.settings.max});
            // this fileSelector same as the one used in StaticImage. Help read new upload for Add and Replace Function.
            _this.fileSelector = $('<input/>', {type: 'file'}).on('change', function(e) {
                // Added the read file function here as tried to copy from staticImage to put at handlefile but failed.
                var file = e.target.files[0];   // only get first file...
                if (typeof file == 'undefined' || typeof file == null)
                {
                    return;
                }
                var reader = new FileReader();
                reader.onloadend = function() {
                    var url = reader.result;
//                    resizeImage(url,300,300, 0.5, function (url) { // Different from StaticImage Resize, this re-size all image to 400 x 300 or 300 x 400 depending if it is landscape or potrait.
                    resizeImageCamera(url, 0.5, function(url) {
                        if (_this.fileButton === '')
                        { // for add image function
                            _this.imageElement = $('<img/>', {src: _this.settings.value});
                            _this.imageElement.addClass('imageId');
                            function two(num) { //forces number to 2 digits
                                var num = ("0" + num).slice(-2);

                                return num;
                            }
                            var now = new Date();

                            var hideImgDate = $(_this.selector).attr('data-hideimagedate');

                            var hideImgTime = $(_this.selector).attr('data-hideimagetime');

                            //attempt to use options.hideimagedate and options.hideimagetime but it wont work for brand new job schedule.
                            if (hideImgDate == 'true' && hideImgTime == 'true')
                            {
                                var now = "";

                            }
                            else if (hideImgDate == 'true' && hideImgTime == 'false')
                            {
                                var now = two(now.getHours()) + ":"
                                    + two(now.getMinutes()) + ":"
                                    + two(now.getSeconds());

                            }
                            else if (hideImgDate == 'false' && hideImgTime == 'true')
                            {
                                var now = two(now.getDate()) + "/"
                                    + two(now.getMonth() + 1) + "/"
                                    + two(now.getFullYear());

                            }
                            else
                            {
                                var now = two(now.getDate()) + "/"
                                    + two(now.getMonth() + 1) + "/"
                                    + two(now.getFullYear()) + " "
                                    + two(now.getHours()) + ":"
                                    + two(now.getMinutes()) + ":"
                                    + two(now.getSeconds());

                                //var formatDate = date.getDate().pad(2) + "/" + date.getMonth().pad(2) + "/" + date.getFullYear().toString().substr(-2) + " " + date.getHours().pad(2)+ ":" + date.getMinutes().pad(2) + ":" + date.getSeconds().pad(2);

                            }
                            _this.imageElement.attr('data-timestamp', now);
                            _this.imageElement.attr('data-block-unit', '0'); // This field will affect PDF
                            _this.imageElement.attr('data-block-level', '0'); //This field will affect PDF
                            _this.imageElement.attr('data-latitude', '0');
                            _this.imageElement.attr('data-longitude', '0');
                            _this.imageElement.css('background-color', 'rgb(0, 0, 0');
                            _this.imageElement.attr('onclick', '$(this).toggleClass(\'selected\');');
                            if ($(_this.selector + ' div.' + _this.role).children().hasClass('selected'))
                            { //_this.selector = id
                                var x = 0;

                                $(_this.selector + ' div.' + _this.role).children().each(function() {  // this code can be further improve to be a single line.
                                    if ($(this).hasClass('selected'))
                                    {
                                        x = $(this).index();

                                        return false;
                                    }
                                });

                                _this.imageElement.insertBefore(container.find('img').eq(x));
                            }
                            else
                            {
                                _this.imageElement.insertBefore(container.find('input').first());

//                                if(container.has('input')){ // will need to consider this after solving the camera img showing after it pass through mobile side
//                                } else{
//                                    container.append(_this.imageElement); // Just in case for those that dont have camera img element inside for old report.
//                                }
                            }
                            _this.imageElement.attr('src', url);

                        }
                        else
                        {
                            $(_this.selector + ' div.' + _this.role).children().eq(_this.fileButton).attr('src', url); // for replace image function, get the selected picture and change the src
                        }
                    });

                };
                if (file)
                {
                    var imageType = /image.*/;
                    if (file.type.match(imageType))
                    {
                        reader.readAsDataURL(file);

                    }
                    else
                    {
                        _this.imageElement.attr('src', '');

                    }
                }
                else
                {
                    _this.imageElement.attr('src', '');

                }
                // Original Code
                // container.prepend(_this.imageElement); // used prepend instead of append so as not to mess up the mobile code
                //field.append(container);
            });
            container.append(_this.settings.value); //adding all the current image into the list
            //Currently remove the following "if check"  (Problem with adding it is that if user add image before scheduling the job, it will cause problem at the mobile phone side)
            // if (_this.settings.value.length === 0) // only when there is no pre-add image, the camera icon will appear for user to add image at mobile side
            //{
            // a mobile requirement that sets to use input type image...
            var image = $('<input/>', {type: 'image', src: 'img/form_camera.png'}).on('click', function() {
                return false;
            });

            var gallery = $('<input/>', {type: 'image', src: 'img/form_gallery.png'}).on('click', function() {
                return false;
            });

            container.append(image);

            container.append(gallery);

            //}
            _this.input = container;
            field.append(container);
            _this.fieldMenu.enableGeotag = true;
            _this.fieldMenu.enableBackup = true;
            _this.fieldMenu.enablePreview = false;
            _this.fieldMenu.enableEditable = false;
            _this.fieldMenu.enableMandatory = false;
            _this.fieldMenu.hideImageDate = true;
            _this.fieldMenu.hideImageTime = true;
            _this.fieldMenu.enableCompute = false;
        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);
            var field = $(parent.selector);

            /*
             * creates minimum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMinimum + '</label>');
            var inputContainer = $('<div/>');
            var inputMin = $('<input/>', {type: 'range', min: 0, max: 20, value: _this.settings.min}).on('change', function() {
                $(parent.fieldMenu.selector + '-mandatory').prop('checked', (this.value > 0));
                _this.input.attr('data-min', this.value);

            });
            inputMin.on('mousemove', function() {
                $(inputMin).siblings('span').html(this.value);

            });
            // make the change immediately to take effect on the form field...
            inputMin.change();
            inputContainer.append(inputMin);
            inputContainer.append($('<span/>').html(_this.input.attr('data-min')));
            fieldMenu.append(inputContainer);
            /*
             * creates maximum photos...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorMaximum + '</label>');
            inputContainer = $('<div/>');
            var inputMax = $('<input/>', {type: 'range', min: 1, max: 20, value: _this.settings.max}).on('change', function() {
                _this.input.attr('data-max', this.value);

            });
            inputMax.on('mousemove', function() {
                $(inputMax).siblings('span').html(this.value);

            });
            // make the change immediately to take effect on the form field...
            inputMax.change();
            inputContainer.append(inputMax);
            inputContainer.append($('<span/>').html(_this.input.attr('data-max')));
            fieldMenu.append(inputContainer);
            var hintContainer = $('<div/>', {class: 'input-control textarea full-size'});
            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');
            var hintBox = $('<textarea/>', {rows: 5}).on('change', function() {
                $(field.selector + '-hint').html(this.value);
                var value = this.value;
                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });
            hintBox.html(_this.settings.hint);
            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);
            //*added new buttons for adding/replacing/deleting image for this field.
            addEditDeleteButton(_this, fieldMenu, _this.role);

        }
    };
    _this = $.extend(new FormField(), _this, options);
    return _this;
};

var EmbeddedURL = function(options) {
    var _this = {
        role: 'embeddedURL',
        fieldMenuTitle: 'Embedded Link',
        settings: {
            src: '',
            id: '',
            hint: null
        },
        input: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);
            var frameSrc;
            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            
            

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);
            
            var frame =  $('<iframe/>', {
                id: _this.selector.substring(1) + '-frame-video',
                class: 'video-frame',
                style: 'display:block',
                width:"300",
                height:"261",
                allowfullscreen:true,
                src:_this.settings.src
            });

            _this.input = $('<input/>', {
                type: 'text',
                value: _this.settings.value,
                disabled: false
            }).on('change', function() {
                _this.input.attr("value", this.value);
                 _this.settings.src = frameSrc = this.value;
                 frame.attr('src', frameSrc);
                
            });
            
           
            
            field.append(_this.input);
            field.append(frame);
            //_this.appendButtons(field);

            _this.fieldMenu.enableColumnize = false;
            _this.fieldMenu.enableCompute = false;
            _this.fieldMenu.enableMandatory = false;
            _this.fieldMenu.enableEditable  = false;
            _this.fieldMenu.enablePreview  = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });


            fieldMenu.append(inputContainer);
            $(field.selector).attr('data-editable', false);


            inputContainer = $('<div/>');


            fieldMenu.append(inputContainer);


        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};


var OTPField = function(options) {
    var _this = {
        role: 'otp',
        fieldMenuTitle: 'OTP',
        settings: {
            maxlength: 50,
            value: '',
            id: '',
            otpVal: '',
            hint: null
        },
        input: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<input/>', {
                type: 'number',
                class:'cust-no',
                value: _this.settings.value
            }).on('change', function() {
                _this.input.attr("value", this.value);

            });
            
            var sendLink =  $('<a/>',{
                id: _this.selector.substring(1) + '-send-otp',
                class: 'send-otp',
                style: 'display:block;text-decoration:underline;cursor:pointer;font-weight:bold',
                value:_this.selector.substring(1)
            }).html('Send OTP');
            
            var otpLabel = $('<label/>', {
                id: _this.selector.substring(1) + '-label',
                class: 'send-label',
                style: 'display:block'
            }).html('Enter OTP');
            
            var otpField = $('<input/>', {
                type: 'number',
                class:'otp-field',
                disabled: true,
                value: _this.settings.otpVal
            }).on('change', function() {
              otpField.attr('value', this.value);

            });
            
            var verifyLink =  $('<a/>',{
                id: _this.selector.substring(1) + '-verify-otp',
                class: 'verify-otp',
                style: 'display:block;text-decoration:underline;cursor:pointer;font-weight:bold',
                value:   _this.selector.substring(1)
            }).html('Verify OTP');

            field.append(_this.input);

            field.append(sendLink);
            
            field.append(otpLabel);
            
            field.append(otpField);
            
            field.append(verifyLink);
            
         

            _this.fieldMenu.enableColumnize = true;

            _this.fieldMenu.enableCompute = false;
            
            _this.fieldMenu.enablePreview  = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates placeholder input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorPlaceholder + '</label>');

            var inputContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var inputLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.placeholder
            }).on('change', function() {
                _this.input.attr("placeholder", this.value);

            });

            // make the change immediately to take effect on the form field...
            inputLabel.change();

            inputContainer.append(inputLabel);

            fieldMenu.append(inputContainer);


            fieldMenu.append(inputContainer);


            /*
             * creates ID input...
             */
            fieldMenu.append('<label>' + _this.form.options.language.formEditorId + '</label>');

            var idContainer = $('<div/>', {
                class: 'input-control text full-size'
            });

            var idLabel = $('<input/>', {
                type: 'text',
                value: _this.settings.id,
                disabled: 'true'
            }).on('change', function() {
                _this.input.attr("id", this.value);

            });

            idLabel.change();

            idContainer.append(idLabel);

            fieldMenu.append(idContainer);

        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};



var TimeCapture = function(options) {
    var _this = {
        create: function(field) {
            
           var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);

            _this.input = $('<label/>');
            
            _this.input = $('<input/>', {
                type: 'image',
                src: 'img/form_time_capture.png'
            }).on('click', function() {
                return false;
            });
            
            field.append(_this.input);
            
            _this.timeLabel = $('<label/>');
            
            field.append(_this.timeLabel);
            
            _this.fieldMenu.enableGeotag = false;

            _this.fieldMenu.enableBackup = false;

            _this.fieldMenu.enablePreview = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableMandatory = true;

            _this.fieldMenu.enableCompute = false;
			
            _this.fieldMenu.enableColumnize = false;

        }
    };

    _this = $.extend(new Label(), _this, options);

    _this.role = 'timeCapture';

    _this.fieldMenuTitle = 'Time Capture';

    return _this;
};





/*
 for collapser form field to use...
 */
function toggleCollapser(id, count) {
    // collapse all the collapsers except the one the user clicked on...
    $('.collapser.expand').each(function() {
        var div = $(this).parent();

        if (div.attr('id') !== id)
        {
            div.nextAll(':lt(' + div.attr('data-max') + ')').toggle();

            $(this).removeClass('expand');

        }
    });

    var collapser = $('#' + id);

    collapser.nextAll(':lt(' + count + ')').toggle();

    collapser.children(':first').toggleClass('expand');

    $('#form-template').animate({
        scrollTop: collapser.offset().top
    }, 1500);

}
// use for camera and gallery function
function addEditDeleteButton(_this, fieldMenu, role) {
    var buttonUpload = $('<button/>', {
        type: 'button',
        class: 'toolbar-button',
        title: _this.form.options.language.formEditorAddImage
    }).html('<span class="mif-plus"></span>').on('click', function() {
        var elementCount = $(_this.selector + ' div.' + _this.role).children().length
        var dataMax = $(_this.selector + ' div.' + _this.role).attr('data-max');

        if (elementCount > dataMax)
        {
            dialog('Max Images Attached', 'You have reached the max amount of images.', 'alert')
        }
        else
        {
            _this.fileButton = '';

            _this.fileSelector.click();

        }
    });

    var buttonReplace = $('<button/>', {
        type: 'button',
        class: 'toolbar-button',
        title: _this.form.options.language.formEditorReplaceImage
    }).html('<span class="mif-redo"></span>').on('click', function() {
        // Check if there is any selected img
        if ($(_this.selector + ' div.' + role).children().hasClass('selected'))
        {
            $(_this.selector + ' div.' + role).children().each(function() { // this code can be further improve to be a single line.
                if ($(this).hasClass('selected'))
                {
                    _this.fileButton = $(this).index();

                    _this.fileSelector.click();

                    return false;
                }
            });

        }
        else
        {
            dialog('No Image Selected', 'Please select a image to edit', 'alert');

        }
    });

    ;

    var buttonDelete = $('<button/>', {
        type: 'button',
        class: 'toolbar-button',
        title: _this.form.options.language.formEditorDeleteImage
    }).html('<span class="mif-cross"></span>').on('click', function() {
        // Check if there is any selected img
        if ($(_this.selector + ' div.' + role).children().hasClass('selected'))
        {
            // can prompt confirmation dialog
            var c = confirm("Are you sure you want to delete these images?");

            if (c === true)
            {
                $(_this.selector + ' div.' + role).children().each(function() { // this code can be further improve to be a single line.
                    if ($(this).hasClass('selected'))
                    {
                        $(this).remove();

                    }
                });

            }
        }
        else
        {
            dialog('No Image Selected', 'Please select a image to delete', 'alert');

        }
    });

    var toolbarSection = $('<div/>', {
        class: 'toolbar-section'
    });

    toolbarSection.append(buttonUpload);

    toolbarSection.append(' '); // must add this manually...
    toolbarSection.append(buttonReplace);

    toolbarSection.append(' '); // must add this manually...
    toolbarSection.append(buttonDelete);

    toolbarSection.insertAfter(fieldMenu.find('.toolbar-section'));

}


var File = function(options) {
    var _this = {
        role: 'file',
        fieldMenuTitle: 'File',
        settings: {
            value: '',
            hint: null,
            fileName: ''
        },
        fileSelector: null,
        anchorElement: null,
        create: function(field) {
            var hintVal = $(field.selector + '-hint').html(); // remember the hint before it is gone after the below code...
            var hint = $('<label/>', {
                id: _this.selector.substring(1) + '-hint',
                class: 'hint-label',
                style: 'display:none'
            }).html(hintVal);

            var buttonHint = $('<button/>', {
                type: 'button',
                id: _this.selector.substring(1) + '-buttonHint',
                class: 'hint-button',
                style: 'display:none'
            }).html('');

            field.append(buttonHint);

            buttonHint.attr('onclick', '$(\'' + _this.selector + '-hint' + '\').toggle();');

            if (hintVal && hintVal.length > 0)
            {
                buttonHint.css('display', 'block');

            }
            field.append(hint);
            
            /*
             * creates a button to upload file...
             */
//            var buttonUpload = $('<button/>', {
//                type: 'button',
//                class: 'button primary'
//            }).html('<span>' + _this.form.options.language.formEditorBrowse + '</span>').on('click', function() {
//                _this.fileSelector.click();
//
//            });
//            
//            field.append(buttonUpload);

            _this.fileSelector = $('<input/>', {
                type: 'file'
            }).on('change', _this.handleFile);

            var container = $('<div/>', {
                class: _this.role
            });

            _this.anchorElement = $('<a/>', {
                target: '_blank',
                href: _this.settings.value
            }).html(_this.settings.fileName);

            container.append(_this.anchorElement);

            field.append(container);

            _this.fieldMenu.enableMandatory = false;

            _this.fieldMenu.enableEditable = false;

            _this.fieldMenu.enableCompute = false;
            
            _this.fieldMenu.enablePreview = false;

        },
        createMenu: function(parent) {
            var fieldMenu = $(parent.fieldMenu.selector);

            var field = $(parent.selector);

            /*
             * creates a button to upload file...
             */
            var buttonUpload = $('<button/>', {
                type: 'button',
                class: 'button primary'
            }).html('<span>' + _this.form.options.language.formEditorBrowse + '</span>').on('click', function() {
                _this.fileSelector.click();
            });

            fieldMenu.append(buttonUpload);
            
            /*
             * creates a button to remove file...
             */
            var buttonRemove = $('<button/>', {
                type: 'button',
                class: 'button primary',
                style: 'margin-left: 10px'
            }).html('<span>' + _this.form.options.language.formEditorRemove + '</span>').on('click', _this.removeFile);
            
            fieldMenu.append(buttonRemove);

            var hintContainer = $('<div/>', {
                class: 'input-control textarea full-size'
            });

            hintContainer.append('<label>' + _this.form.options.language.formEditorHint + '</label>');

            var hintBox = $('<textarea/>', {
                rows: 5
            }).on('change', function() {
                $(field.selector + '-hint').html(this.value);

                var value = this.value;

                if (value && value.length > 0)
                {
                    $(field.selector + "-buttonHint").css('display', 'block');

                }
                else
                {
                    $(field.selector + "-buttonHint").hide();

                }
            });

            hintBox.html(_this.settings.hint);

            // make the change immediately to take effect on the form field...
            hintBox.change();

            hintContainer.append(hintBox);

            fieldMenu.append(hintContainer);

        },
        handleFile: function(e) {
            
            var file1 = e.target.files[0];
            
            var formData = new FormData();
            
            formData.append("file", file1);
            
            if (file1 !== null && file1 != 'undefined') {
                
                var fileName = e.target.files[0].name;
                
                var index = fileName.lastIndexOf(".");
                
                var name = fileName.substring(0, index);

                var extension = fileName.substring(index);

                if(extension === '.PDF')
                {
                    extension = extension.toLowerCase();
                }

                var filename = name + extension;

                $.ajax({
                    type: "POST",
                    encType: "multipart/form-data",
                    url: "JobFormFieldFileUploadController?filename=" + encodeURIComponent(filename) + "&action=upload",
                    cache: false,
                    processData: false,
                    contentType: false,
                    data: formData,
                    success: function (data) {

                        if(data.result !== undefined && data.result === true)
                        {
                            dialog('Success', data.message, 'success');
                            
                            _this.anchorElement.attr('href', data.url);
                         
                            _this.anchorElement.html(data.filename);

                            _this.settings.fileName = data.filename;
                        }
                        else
                        {
                            dialog('Couldn\'t attach file', data.message, 'alert');
                        }

                    },
                    error: function (data) {
                        
                        dialog('Couldn\'t attach file', data.message, 'alert');
                    }

                });
            }
        },
        removeFile: function(e) {
            if (_this.settings.fileName !== '') {

                $.ajax({
                    type: "POST",
                    url: "JobFormFieldFileUploadController?filename=" + encodeURIComponent(_this.settings.fileName) + "&action=remove",
                    cache: false,
                    processData: false,
                    contentType: false,
                    success: function (data) {

                        if(data.result !== undefined && data.result === true)
                        {
                            dialog('Success', data.message, 'success');
                            
                            _this.anchorElement.attr('href', '');
                         
                            _this.anchorElement.html('');

                            _this.settings.fileName = '';
                        }
                        else
                        {
                            dialog('Couldn\'t remove file', data.message, 'alert');
                        }

                    },
                    error: function (data) {
                        
                        dialog('Couldn\'t remove file', data.message, 'alert');
                    }

                });
            }
        }
    };

    _this = $.extend(new FormField(), _this, options);

    return _this;
};

