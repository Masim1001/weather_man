require 'colorize'

def converetPathInFileName(year,month,path)
    if path.include?("lahore_weather")
        path = path + "/" + "lahore_weather"
    elsif path.include?("Murree_weather")
        path = path + "/" + "Murree_weather"
    elsif path.include?("Dubai_weather")
        path = path + "/" + "Dubai_weather"
    end

    file_name = path + "_" + year + "_" + month + ".txt"
    return file_name
end

def breakYearMonth(givenMonth,flag, path)
    begin
        arr = givenMonth.split('/')
        mon = arr[1].to_i  # If month string contain "06" then after converting to int 0 will be neglected
        month = {"1"=>"Jan","2"=>"Feb", "3"=>"Mar","4"=>"Apr", "5"=>"May", "6"=>"Jun",
         "7"=>"Jul", "8"=>"Aug", "9"=>"Sep", "10"=>"Oct", "11"=>"Nov", "12"=>"Dec"}
        arr[1] = month[mon.to_s] 
        givenMonth(arr[0],arr[1],flag, path)
    rescue Exception => e
        puts "ERROR! Arguments are not in correct Format".red
    end   
end

def givenMonth(year,month, flag, path)
    file_name = converetPathInFileName(year,month,path)
    if File.exists?(file_name) != true
        if flag != "-e"
            puts "File does not Exists".red
        end
    else 
        lines = File.readlines(file_name)
        totalFileLines = lines.length
        #Remove bottom lines which does not cotain data
        totalDataLines = 0
        for i in 0..(totalFileLines-1)
            if lines[i].include?"<!"
                break
            end
            totalDataLines= totalDataLines + 1
        end
        #To remove empty lines from starting doesn't matter if it 1 or more
        startIndex = 0
        for i in 0..(totalDataLines-1)
            if lines[i] != "\n"  
                startIndex = i
                break
            end
        end
        dataLine1 = lines[startIndex].gsub(/[\s]*,[\s]*/, ',').split(',')  #Here gsub is used to remove spaces around ','
        maxTempIndex = dataLine1.find_index("Max TemperatureC")
        minTempIndex = dataLine1.find_index("Min TemperatureC")
        if flag == "-c"
            fullMonthName = { "Jan"=>"January", "Feb"=>"February", "Mar"=>"March", "Apr"=>"Aprial", "May"=>"May", "Jun"=>"June",
                "Jul"=>"July", "Aug"=>"August", "Sep"=>"September", "Oct"=>"October", "Nov"=>"November", "Dec"=>"December"}
            puts "#{fullMonthName[month]} #{year}"
            displayTwoHorizontalBarChart(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex)
            puts "------ Bonus Task ------"
            sleep(1)
            puts "#{fullMonthName[month]} #{year}"
            displayOneHorizontalBarChart(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex)
        elsif flag == "-a"
            meanHumidityIndex = dataLine1.find_index("Mean Humidity")
            displayAvgTempAndHumidity(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex, meanHumidityIndex)
        elsif flag == "-e"
            maxHumidityIndex = dataLine1.find_index("Max Humidity")
            return findMaxMinTempAndMaxHumidityPerMonth(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex, maxHumidityIndex)
        end

    end
end

def findMaxMinTempAndMaxHumidityPerMonth(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex, maxHumidityIndex)
    maxTemp = -10000
    maxTempDay = -1
    minTemp = 10000
    minTempDay = -1
    maxHumidity = -10000
    maxHumidityDay = -1
    for i in (startIndex+1)..(totalDataLines-1)  #We start from startIndex+1 because at startIndex Data name is written
        #ignore empty lines that contain between data
        if lines[i] != "\n"
            maxVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](maxTempIndex)
            if maxVal != nil and maxVal != ""
                if maxVal.to_i > maxTemp
                    maxTemp = maxVal.to_i
                    maxTempDay = i - startIndex
                end
            end

            minVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](minTempIndex)
            if minVal != nil and minVal != ""
                if minVal.to_i < minTemp
                    minTemp = minVal.to_i
                    minTempDay = i  - startIndex
                end
            end
    
            maxValHum = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](maxHumidityIndex)
            if maxValHum != nil and maxValHum != ""
                if maxValHum.to_i > maxHumidity
                    maxHumidity = maxValHum.to_i
                    maxHumidityDay = i  - startIndex
                end
            end
        end
    end
    data = {}
    data["maxTempDay"] = maxTempDay
    data["maxTemp"] = maxTemp
    data["maxHumidityDay"] = maxHumidityDay
    data["maxHumidity"] = maxHumidity
    data["minTempDay"] = minTempDay
    data["minTemp"] = minTemp
   
    return data
end

def givenYear(year, path)
    month = { 1=>"Jan", 2=>"Feb", 3=>"Mar", 4=>"Apr", 5=>"May", 6=>"Jun",
        7=>"Jul", 8=>"Aug", 9=>"Sep", 10=>"Oct", 11=>"Nov", 12=>"Dec"}
    fullMonthName = { "Jan"=>"January", "Feb"=>"February", "Mar"=>"March", "Apr"=>"Aprial", "May"=>"May", "Jun"=>"June",
        "Jul"=>"July", "Aug"=>"August", "Sep"=>"September", "Oct"=>"October", "Nov"=>"November", "Dec"=>"December"}
    maxTemp = -10000
    minTemp = 10000
    maxHumidity = -10000
    maxTempDay = -1
    minTempDay = -1
    maxHumidityDay = -1
    maxTempMonth = ""
    minTempMonth = ""
    maxHumidityMonth = ""
    count = 0

    for i in 1..12
        #it will return the hash of data with value and day
        data = givenMonth(year,month[i],"-e",path) # If file does not exist it will return nil
        if data != nil  
            if data["maxTemp"] > maxTemp
                maxTemp = data["maxTemp"]
                maxTempDay = data["maxTempDay"]
                maxTempMonth = month[i]
            end
            if data["minTemp"] < minTemp
                minTemp = data["minTemp"]
                minTempDay = data["minTempDay"]
                minTempMonth = month[i]
            end
            if data["maxHumidity"] > maxHumidity
                maxHumidity = data["maxHumidity"]
                maxHumidityDay = data["maxHumidityDay"]
                maxHumidityMonth = month[i]
            end
        else
            count += 1
        end
    end
    #If count = 12 it means there is no such file regarding to given year
    if count == 12
        puts "In this folder There is no such file regarding to this Year".red
    else
        #What if files exits but there is no data in all files?
        #So we use check to deafult values to resolve this issue
        if maxTemp != -10000
            puts "Highest: #{maxTemp}C on #{fullMonthName[maxTempMonth]} #{maxTempDay}"
        else
            puts "There is no data for Max Temperature".red
        end
        if minTemp != 10000
            puts "Lowest: #{minTemp}C on #{fullMonthName[minTempMonth]} #{minTempDay}"
        else
            puts "There is no data for Min Temperature".red
        end
        if maxHumidity != -10000
            puts "Humid: #{maxHumidity}% on #{fullMonthName[maxHumidityMonth]} #{maxHumidityDay}"
        else
            puts "There is no data for Max Humidity".red
        end 
    end
end


#I need to make it class to solve it better
def displayAvgTempAndHumidity(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex, meanHumidityIndex)
    maxTempSum = 0
    avgMaxTemp = 0
    totalNumOfMaxTempData = 0
    minTempSum = 0
    avgMinTemp = 0
    totalNumOfMinTempData = 0
    meanHumiditySum = 0
    avgMeanHumidity = 0   
    totalNumOfMeanHumidityData = 0

    for i in (startIndex+1)..(totalDataLines-1)  #We start from startIndex+1 because at startIndex Data name is written
        #ignore empty lines that contain between data
        if lines[i] != "\n"
            maxVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](maxTempIndex)
            if maxVal != nil and maxVal != ""
                maxTempSum += maxVal.to_i
                totalNumOfMaxTempData += 1
            end

            minVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](minTempIndex)
            if minVal != nil and minVal != ""
                minTempSum += minVal.to_i
                totalNumOfMinTempData += 1
            end
    
            meanVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](meanHumidityIndex)
            if meanVal != nil and meanVal != ""
                meanHumiditySum += meanVal.to_i
                totalNumOfMeanHumidityData += 1
            end

        end
    end
    
    #Exception handling for the case if totalNumOfMaxTempData = 0
    begin
        avgMaxTemp = (maxTempSum / (totalNumOfMaxTempData.to_f)).round()
        puts "Highest Average: #{avgMaxTemp}C"
    rescue Exception => e
        puts "There is no data for Highest Temperature"
    end
    begin
        avgMinTemp = (minTempSum / (totalNumOfMinTempData.to_f)).round()
        puts "Lowest Average: #{avgMinTemp}C"
    rescue Exception => e
        puts "There is no data for Lowest Temperature"
    end
    begin
        avgMeanHumidity = (meanHumiditySum / (totalNumOfMeanHumidityData.to_f)).round()
        puts "Average  Humidity: #{avgMeanHumidity}%"
    rescue Exception => e
        puts "There is no data for Highest Temperature"
    end

end

def displayTwoHorizontalBarChart(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex)
    for i in (startIndex+1)..(totalDataLines-1)  #We start from startIndex+1 because at startIndex Data name is written
        #ignore empty lines that contain between data
        if lines[i] != "\n"
            maxVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](maxTempIndex)
            if maxVal != nil and maxVal != ""
                maxTemp = maxVal.to_i
                print "#{i-startIndex} "
                if maxTemp > 0 
                    for j in 1..maxTemp
                        print "+".red
                    end
                elsif maxTemp < 0
                    for j in maxTemp..-1
                        print "-".red
                    end
                end
                puts " #{maxTemp}C"
            end

            minVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](minTempIndex)
            if minVal != nil and minVal != ""
                minTemp = minVal.to_i
                print "#{i-startIndex} "
                if minTemp > 0 
                    for j in 1..minTemp
                        print "+".blue
                    end
                elsif minTemp < 0
                    for j in minTemp..-1
                        print "-".blue
                    end
                end
                puts " #{minTemp}C"
                sleep(0.8)
            end
        end
    end

end


def displayOneHorizontalBarChart(lines, startIndex, totalDataLines, maxTempIndex, minTempIndex)
    for i in (startIndex+1)..(totalDataLines-1)  #We start from startIndex+1 because at startIndex Data name is written
        #ignore empty lines that contain between data
        if lines[i] != "\n"
            dayFlagMaxTemp = false
            dayFlagMinTemp = false
            maxVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](maxTempIndex)
            minVal = (lines[i].gsub(/[\s]*,[\s]*/, ',').split(',')).[](minTempIndex)

            if minVal != nil and minVal != ""
                minTemp = minVal.to_i
                print "#{i-startIndex} "
                dayFlagMinTemp = true
                if minTemp > 0 
                    for j in 1..minTemp
                        print "+".blue
                    end
                elsif minTemp < 0
                    for j in minTemp..-1
                        print "-".blue
                    end
                end
            end

            if maxVal != nil and maxVal != ""
                maxTemp = maxVal.to_i
                if dayFlagMinTemp == false
                    print "#{i-startIndex} "
                end
                dayFlagMaxTemp = true
                if maxTemp > 0 
                    for j in 1..maxTemp
                        print "+".red
                    end
                elsif maxTemp < 0
                    for j in maxTemp..-1
                        print "-".red
                    end
                end
            end

            if dayFlagMinTemp == true
                print " #{minTemp}C -"
            end
            if dayFlagMaxTemp == true
                puts " #{maxTemp}C"
                sleep(0.8)
            elsif dayFlagMinTemp == true and 
                print "\n"
                sleep(0.8)
            end

           
        end
    end

end

# <Driver Code>
flag = ARGV[0]
year = ARGV[1]
path = ARGV[2]

case flag
    when "-a","-c"
        breakYearMonth(year , flag , path)
    when "-e"
        givenYear(year, path)
    else
        puts "ERROR!!! First argument must be -a or -c or -e"
    end