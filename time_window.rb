require 'yaml'

class TimeWindow
	@@weekDays = "Mon Tue Wed Thu Fri Sat Sun Mon Tue Wed Thu Fri Sat Sun"
	@@filterStructure = { :days => [], :time => []}

	def initialize(rangeString)
		@rangeString = rangeString
		@filter = createFilter()
	end

	def include?(checkTime)
		return false if(!checkTime.instance_of?(Time))

		@filter.each do |filter|
			return true if(inRange?(filter, checkTime))
		end
		return false
	end

	private
	def inRange?(filter, checkTime)
		days = filter[:days]
		timeRange = filter[:time]
		inDays = true
		inTime = true
		checkHr = checkTime.hour
		checkMin = checkTime.min

		inDays = false if !days.empty? && !days.include?(checkTime.strftime "%a")
		inTime = false if !timeRange.empty?

		i = 0
		while i < timeRange.length
			if(checkHr >= timeRange[i] && checkHr < timeRange[i+2])
				if(checkMin >= timeRange[i+1] && checkMin <= (timeRange[i+3] = 0 ? 59 : timeRange[i+3]))
					inTime = true
				end
			end
			i = i + 4
		end

		return inDays && inTime
	end

	def createFilter()
		filter = []
		return filter.push(@@filterStructure) if @rangeString.empty?

		filterArr = @rangeString.split('; ')

		filterArr.each do |x|
			filterElement = { :days => [], :time => []}

			filterTypes = x.split(' ')

			filterTypes.each do |y|
				case y
				when /[A-Z]?[a-z]{2,2}-[A-Z]?[a-z]{2,2}/
					tmp = y.split('-')
					strStart = tmp[0]
					strEnd = tmp[1]
					filterElement[:days].concat(@@weekDays.slice(/#{strStart}[^#{strStart}.]*#{strEnd}/).split(' '))
				when /[A-Z]?[a-z]{2,2}/
					filterElement[:days].push(y)
				when /[0-9]{4,4}-[0-9]{4,4}/
					tmp = y.split('-')
					startTime = tmp[0]
					endTime = tmp[1]
					filterElement[:time].push(startTime[0,2].to_i).push(startTime[2,2].to_i)
					filterElement[:time].push(endTime[0,2].to_i).push(endTime[2,2].to_i)
				end
			end
			filter.push(filterElement)
		end
		filter
	end
end
