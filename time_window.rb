require 'yaml'

class TimeWindow
	@@weekDays = "Mon Tue Wed Thu Fri Sat Sun Mon Tue Wed Thu Fri Sat Sun"

	def initialize(rangeString)
		@rangeString = rangeString
		@filter = createFilter()
	end

	private
	def createFilter()
		filter = []
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
		puts filter.to_yaml
	end
end
