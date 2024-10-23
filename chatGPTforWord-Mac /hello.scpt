on runAppleScriptTask(prompt)
    -- Define the API URL
    set apiURL to "https://open.bigmodel.cn/api/paas/v4/chat/completions"

    -- Define the Authorization token
    set authToken to "982513b625cbddeb2887cb5913e74764.VI9I9SfnLNuB3k1P"


    -- Define the JSON payload with the escaped prompt parameter
    set jsonPayload to "{\"model\":\"glm-4-plus\",\"messages\":[{\"content\":\"" & prompt & "\",\"role\":\"user\"}],\"temperature\":0.7,\"top_p\":1}"
		-- display dialog jsonPayload


    -- Calculate the length of the JSON payload
    set contentLength to length of jsonPayload

    -- Define the path to jq (adjust if necessary)
    set jqPath to "/usr/local/bin/jq"

    -- Construct the curl command
    set curlCommand to "curl -s --connect-timeout 60 --max-time 180 --location " & ¬
        "-H 'Authorization: Bearer " & authToken & "' " & ¬
        "-H 'Accept: application/json;' " & ¬
        "-H 'Content-Type: application/json;' " & ¬
        "-X POST " & ¬
        "-d " & quoted form of jsonPayload & " " & ¬
        quoted form of apiURL

		-- display dialog curlCommand


		try
    -- Execute curl in the background
    do shell script curlCommand & " > /tmp/curl_output.txt &"

    repeat
    delay 1 -- Wait for 1 second
    try
        set curlStatus to do shell script "pgrep -c curl" -- Count running curl processes
        if curlStatus is "0" then exit repeat
    on error
        exit repeat -- Exit if there's an error (e.g., no curl process)
    end try
end repeat
    -- Now read the output
    set extractedContent to do shell script "cat /tmp/curl_output.txt | " & jqPath & " -r '.choices[0].message.content'"

    -- Return only the extracted content
    -- display dialog extractedContent
    return extractedContent
    on error errMsg
        -- Display the error message in a dialog box
        display dialog "Error: " & errMsg
    end try
end runAppleScriptTask

on urlEncode(input)
    set allowedChars to "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.~"
    set output to ""
    repeat with char in input
        if allowedChars contains char then
            set output to output & char
        else
            set asciiNum to ASCII number char
            set hexList to {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"}
            set output to output & "%" & (item ((asciiNum div 16) + 1) of hexList) & (item ((asciiNum mod 16) + 1) of hexList)
        end if
    end repeat
    return output
end urlEncode

on escapeForJSON(theString)
    set resultString to ""
    repeat with theCharacter in theString
        set asciiValue to ASCII number of theCharacter
        if asciiValue is 34 then -- double quote
            set resultString to resultString & "\\\""
        else if asciiValue is 92 then -- backslash
            set resultString to resultString & "\\\\"
        else if asciiValue is 47 then -- forward slash
            set resultString to resultString & "\\/"
        else if asciiValue is 8 then -- backspace
            set resultString to resultString & "\\b"
        else if asciiValue is 12 then -- form feed
            set resultString to resultString & "\\f"
        else if asciiValue is 10 then -- line feed
            set resultString to resultString & "\\n"
        else if asciiValue is 13 then -- carriage return
            set resultString to resultString & "\\r"
        else if asciiValue is 9 then -- tab
            set resultString to resultString & "\\t"
        else if asciiValue < 32 then -- other control characters
            set resultString to resultString & "\\u" & my padLeft(my toHex(asciiValue), 4, "0")
        else
            set resultString to resultString & theCharacter
        end if
    end repeat
    return resultString
end escapeForJSON

on toHex(theNumber)
    set hexChars to "0123456789ABCDEF"
    set hexString to ""
    repeat while theNumber > 0
        set hexString to (character ((theNumber mod 16) + 1) of hexChars) & hexString
        set theNumber to theNumber div 16
    end repeat
    if hexString is "" then set hexString to "0"
    return hexString
end toHex

on padLeft(theString, totalLength, padChar)
    if length of theString ≥ totalLength then return theString
    return text (totalLength - (length of theString)) through -1 of ((totalLength - (length of theString)) * padChar) & theString
end padLeft

--runAppleScriptTask("check script")
