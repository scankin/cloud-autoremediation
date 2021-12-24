//This is purely to be run within an Azure Function, ignore any errors 
#r "Newtonsoft.Json"
#r "System.Net.Http"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Text;
using System;

private static HttpClient HttpClient = new HttpClient();
 
public static async Task<IActionResult> Run(HttpRequest req, ILogger log){
    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);

    string username = "Azure Bot";

    //Collects the information from the log
    string date = data?.data?.alertContext?.condition?.allOf?[0].date;
    string time = data?.data?.alertContext?.condition?.allOf?[0].time;
    string vmName = data?.data?.alertContext?.condition?.allOf?[0].vmName;
    string numProgramsRunning = data?.data?.alertContext?.condition?.allOf?[0].numProgramsRunning;
    string computerUptime = data?.data?.alertContext?.condition?.allOf?[0].computerUptime;
    
    //Alert message
    string alertText = $"{{\"username\": \"{username}\", \"text\": \" A Scale Out has occurred on {date} at {time} \n The CPU on {vmName} has been running above 75% for 2 hours \n The number of prorams running was: {numProgramsRunning} \n The computer uptime was: {computerUptime}\"}}";

    //Creates a HttpRequestMessage which sends a post request to the webhook
    HttpRequestMessage slackMessage = new HttpRequestMessage(HttpMethod.Post, "https://hooks.slack.com/services/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");
    slackMessage.Content = new StringContent(alertText, Encoding.UTF8, "application/json");
 
    //Sends Http Request
    await HttpClient.SendAsync(slackMessage);
 
    return new OkObjectResult("OK");
}