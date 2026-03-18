/*
 * Copyright (C) V3 Smart Technologies. All Rights Reserved.
 *
 * NOTICE:  Proprietary and confidential. This is the Intellectual Property
 * of V3 Smart Technologies Pte Ltd and is not to be used, disclosed or
 * duplicated, either in part or in entirety except with the written approval
 * of V3 Smart Technologies Pte Ltd.
 */

function nokiaReverseGeocode(data, callback)
{
    $.ajax({
        type: 'GET',
        url: 'https://reverse.geocoder.cit.api.here.com/6.2/reversegeocode.json',
        data: {
            app_id: '5DM6u9WMrdPb1l6CZXXS',
            app_code: '9a-2j80gPNU2ABsOKGXFmA',
            gen: 9,
            maxresults: 1,
            prox: data, // includes lat, lon, radius...
            mode: 'retrieveAddresses'
        },
        success: function(data)
        {

            var location = '';

            for (j = 0; j < data.Response.View.length; j++)
            {

                for (i = 0; i < data.Response.View[j].Result.length; i++)
                {

                    var result = data.Response.View[j].Result[i];

                    location = result.Location.Address.Label;

                    break;
                }
            }

            callback(location);
        },
        async: true
    });
}

function reverseGeocode(longitude, latitude, callback)
{
    $.ajax({
        type: 'GET',
        url: 'googleapi?type=geocode&action=reverse',
        data: {
            lon: longitude,
            lat: latitude
        },
        success: function(data)
        {
            var location = '';

            for (i = 0; i < data.results.length; i++)
            {
                var result = data.results[i];

                location = result.formatted_address.toUpperCase();

                break;
            }

            callback(location);
        },
        async: true
    });
}
