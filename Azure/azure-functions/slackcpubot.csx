#r "Newtonsoft.Json"
#r "System.Net.Http"
#r "System.Data"

using System.Net;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Primitives;
using Newtonsoft.Json;
using System.Text;
using System;
using System.Linq;
using System.Data;
using System.Globalization;

private static HttpClient HttpClient = new HttpClient();
 
public static async Task<IActionResult> Run(HttpRequest req, ILogger log){

    string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
    dynamic data = JsonConvert.DeserializeObject(requestBody);

    DateTime localTime = DateTime.Now;
    var uk = new CultureInfo("en-GB");

    string alertMessage = $"A System Scale-Out Occured on {localTime.ToString(uk)} \n";

    foreach(var VM in data.VMs){
        string totalUptime = $"{VM.SystemInfo?.Uptime?.Days} Day(s), {VM.SystemInfo?.Uptime?.Hours} Hour(s), {VM.SystemInfo?.Uptime?.Minutes} Minute(s), {VM.SystemInfo?.Uptime?.Seconds} Seconds";
        alertMessage += $"VMName: {VM.VMName} \n Number of Processes Running: {VM.SystemInfo?.NumProcesses} \n Last Boot Up Time: {VM.SystemInfo?.LastBootup} \n Total Running Time: {totalUptime} \n";
        alertMessage += "The Top 5 Processes are: \n";

        DataTable dt = new DataTable();
        dt.Clear();
        dt.Columns.Add("ID");
        dt.Columns.Add("Name");
        dt.Columns.Add("CPU Metric");

        foreach(var process in VM.Processes){
            DataRow processData =dt.NewRow();
            processData["ID"] = process.ID;
            processData["Name"] = process.Name;
            processData["CPU Metric"] = process.CPUMetric;
            dt.Rows.Add(processData);
        }

        alertMessage += convertDataTable(dt);
        alertMessage += "\n";
    }

    string payload =  $"{{\"username\": \"AzureBot\", \"text\": \"{alertMessage}\"}}";

    //Creates a HttpRequestMessage which sends a post request to the webhook
    HttpRequestMessage slackMessage = new HttpRequestMessage(HttpMethod.Post, "https://hooks.slack.com/services/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");
    slackMessage.Content = new StringContent(payload, Encoding.UTF8, "application/json");
 
    //Sends Http Request
    await HttpClient.SendAsync(slackMessage);
    return new OkObjectResult("OK");

    string convertDataTable(DataTable dt){
        var output = new StringBuilder();

        var columnsWidths = new int[dt.Columns.Count];
        var rowsNum = new int[dt.Rows.Count];

        //Loop through each row in each column individually to get the length of that column
        for(int x = 0; x < dt.Columns.Count; x++){
            int length = 0;
            foreach(DataRow row in dt.Rows){
                if(row[x].ToString().Length > length){
                    length = row[x].ToString().Length;
                    columnsWidths[x] = row[x].ToString().Length;
                }
            }
        }

        // Get Column Titles
        for (int i = 0; i < dt.Columns.Count; i++){
            var length = dt.Columns[i].ColumnName.Length;
               if (columnsWidths[i] < length)
                   columnsWidths[i] = length;
        }

        // Write Column titles
        for (int i = 0; i < dt.Columns.Count; i++){
            var text = dt.Columns[i].ColumnName;
            output.Append("|" + PadCenter(text, columnsWidths[i] + 2));
        }

        output.Append("|\n" + new string('=', output.Length) + "\n");

        // Write Rows
        foreach (DataRow row in dt.Rows){
            for (int i = 0; i < dt.Columns.Count; i++){
                var text = row[i].ToString();
                output.Append("|" + PadCenter(text,columnsWidths[i] + 2));
            }
            output.Append("|\n");
        }
        return output.ToString();
    }

    string PadCenter(string text, int maxLength){
        if(text.Length == maxLength){
            return text;
        }else{
            int diff = maxLength - text.Length;
            return new string(' ', (int) (diff)) + text + new string(' ', (int) (diff));
        }
    } 
}