require_relative 'time_window'

# Write a Ruby class which can tell you whether the current time
# (or any given time) is within a particular "time window."

# Time windows are defined by strings in the following format:
# 0700-0900
# # means every day between these times

# Sat Sun
# # means all day Sat and Sun, no other times

# Sat Sun 0700-0900
# # means 0700-0900 on Sat and Sun only

# Mon-Fri 0700-0900
# # means 0700-0900 on Monday to Friday only

# Mon-Fri 0700-0900; Sat Sun
# # ditto plus all day Sat and Sun

# Fri-Mon 0700-0900
# # 0700-0900 on Fri Sat Sun Mon

# Sat 0700-0800; Sun 0800-0900
# # 0700-0800 on Sat, plus 0800-0900 on Sun

# Time ranges should exclude the upper bound, i.e. 0700-0900 is 07:00:00 to 08:59:59. An empty time window means "all times everyday".

describe "TimeWindow" do

	context "given a blank time window" do
		subject { TimeWindow.new("") }

		let(:arbitrary_time) { Time.mktime(2007,9,25,1,2,3) }

		it "includes all times" do
			expect( subject.include?(arbitrary_time) ).to be_true
		end
	end

	context "given a simple weekly range" do
		subject { TimeWindow.new("Fri-Mon") }

		let(:thursday) { Time.mktime(2007,9,27) }
		let(:friday) { Time.mktime(2007,9,28) }
		let(:saturday) { Time.mktime(2007,9,29) }
		let(:sunday) { Time.mktime(2007,9,30) }
		let(:monday) { Time.mktime(2007,10,1) }
		let(:tuesday) { Time.mktime(2007,10,2) }

		it "does not include Thursday" do
			expect( subject.include?( thursday ) ).to be_false
		end

		it "includes Friday through Monday" do
			expect( subject.include?( friday ) ).to be_true
			expect( subject.include?( saturday ) ).to be_true
			expect( subject.include?( sunday ) ).to be_true
			expect( subject.include?( monday ) ).to be_true
		end

		it "does not include Tuesday" do
			expect( subject.include?( tuesday ) ).to be_false
		end
	end

	context "given a complicated time window" do
		subject { TimeWindow.new("Sat-Sun; Mon Wed 0700-0900; Thu 0700-0900 1000-1200") }

		it "does not include Tuesdays" do
			expect( subject.include?(Time.mktime(2007,9,25,8,0,0)) ).to be_false
		end

		it "includes Wednesday 8AM" do
			expect( subject.include?(Time.mktime(2007,9,26,8,0,0)) ).to be_true
		end

		it "does not include Wednesday 11AM" do
			expect( subject.include?(Time.mktime(2007,9,26,11,0,0)) ).to be_false
		end

		it "does not include Thursday 6:59:59AM" do
			expect( subject.include?(Time.mktime(2007,9,27,6,59,59)) ).to be_false
		end

		it "includes Thursday 7AM" do
			expect( subject.include?(Time.mktime(2007,9,27,7,0,0)) ).to be_true
		end

		it "includes Thursday 8:59:59AM" do
			expect( subject.include?(Time.mktime(2007,9,27,8,59,59)) ).to be_true
		end

		it "does not include Thursday 9AM" do
			expect( subject.include?(Time.mktime(2007,9,27,9,0,0)) ).to be_false
		end

		it "includes Thursday 11AM" do
			expect( subject.include?(Time.mktime(2007,9,27,11,0,0)) ).to be_true
		end

		it "includes Saturday 11AM" do
			expect( subject.include?(Time.mktime(2007,9,29,11,0,0)) ).to be_true
		end

		it "includes Saturday midnight" do
			expect( subject.include?(Time.mktime(2007,9,29,0,0,0)) ).to be_true
		end

		it "includes Saturday 11:59:59PM" do
			expect( subject.include?(Time.mktime(2007,9,29,23,59,59)) ).to be_true
		end
	end

end
