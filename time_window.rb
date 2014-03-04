class TimeWindow
	#week days list(listed twice) - to find all days in a range
	@@weekDays = "Mon Tue Wed Thu Fri Sat Sun Mon Tue Wed Thu Fri Sat Sun"

	def initialize(rangeString)
		#string that holds the initialized range
		@rangeString = rangeString

		#filter which stores the actual filters extracted from given string
		# filter will have this hash { :days => [], :time => []}
		# days will be an array of days in the given range
		# days = ["Sat", "Sun", "Mon"]
		# time will be an array of range
		# 0700-0800 = [7, 0, 8, 0]
		@filter = createFilter()

		#will be set to false if the given rangeString is invalid
		@invalid = false
	end

	def include?(checkTime)
		#if given input is wrong
		return false if !checkTime.instance_of?(Time)

		#if the initialized range is invalid
		return false if @invalid

		#check with every filter in the filters array
		@filter.each do |filter|
			return true if inRange?(filter, checkTime)
		end
		return false
	end

	private
	# this function checks whether the given checkTime(Time) is in filter range or not
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
			if checkHr >= timeRange[i] && checkHr < timeRange[i+2]
				if checkMin >= timeRange[i+1] &&  (timeRange[i+3] = 0 ? (checkMin <= 59) : (checkMin < timeRange[i+3]))
					inTime = true
				end
			end
			i = i + 4
		end

		inDays && inTime
	end

	def createFilter()
		filter = []

		return filter.push({ :days => [], :time => []}) if @rangeString.empty?

		filterArr = @rangeString.split('; ')

		# processing string to a filter hash using regular expressions
		filterArr.each do |x|
			filterElement = { :days => [], :time => []}

			filterTypes = x.split(' ')

			filterTypes.each do |y|
				case y
				when /[A-Z][a-z]{2,2}-[A-Z][a-z]{2,2}/
					# type "Sun-Mon"
					tmp = y.split('-')
					strStart = tmp[0]
					strEnd = tmp[1]
					filterElement[:days].concat(@@weekDays.slice(/#{strStart}[^#{strStart}.]*#{strEnd}/).split(' '))
				when /[A-Z][a-z]{2,2}/
					# type "Sun"
					filterElement[:days].push(y)
				when /[0-9]{4,4}-[0-9]{4,4}/
					# type "0700-0800"
					tmp = y.split('-')
					startTime = tmp[0]
					endTime = tmp[1]
					filterElement[:time].push(startTime[0,2].to_i).push(startTime[2,2].to_i)
					filterElement[:time].push(endTime[0,2].to_i).push(endTime[2,2].to_i)
				else
					#set the object rangeString as invalid
					@invalid = true
				end
			end
			filter.push(filterElement)
		end
		#returns the final filter
		filter
	end
end
