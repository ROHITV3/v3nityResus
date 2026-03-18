/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

var TpsUserRoleListForm = function(filter_id)
{
    var _this = {
        save: function()
        {
            var accessId = document.getElementById('accessId');

            var inputs = document.getElementsByClassName('input-access');

            accessId.value = '';

            for (var i = 0; i < inputs.length; i++)
            {
                if (inputs[i].checked)
                {
                    if (accessId.value.length > 0)
                    {
                        accessId.value += ',';
                    }

                    accessId.value += inputs[i].id;
                }
            }

            return true;
        },
        reset: function()
        {

        },
        populate: function(result)
        {
            for (var i = 0; i < result.access.length; i++)
            {
                var inputId = result.access[i].resource_id + '-' + result.access[i].operation_id;

                var input = document.getElementById(inputId);

                if (input !== null)
                {
                    input.checked = true;
                }
            }
        }
    };

    _this = $.extend(new ListForm(filter_id), _this);

    return _this;
};