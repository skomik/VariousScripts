require 'taglib'
require 'colorize'
require 'work_queue'

def process_file(file)

	TagLib::FileRef.open(file) do |m4a_ref|

		puts "Processing #{file}..."

		wavfile = "mp3/" + file.gsub('.m4a', '.wav')
		mp3file = "mp3/#{'%02d' % m4a_ref.tag.track} - #{m4a_ref.tag.title}.mp3"

		system("afconvert -f WAVE -d LEI16@44100 \"#{file}\" \"#{wavfile}\"")
		system("lame --silent -b 320 \"#{wavfile}\" \"#{mp3file}\"")

		File.delete(wavfile)

		TagLib::MPEG::File.open(mp3file) do |mp3_ref|

			mp3_id3v2_tag = mp3_ref.id3v2_tag

			mp3_id3v2_tag.artist  = m4a_ref.tag.artist
			mp3_id3v2_tag.album   = m4a_ref.tag.album
			mp3_id3v2_tag.genre   = m4a_ref.tag.genre
			mp3_id3v2_tag.title   = m4a_ref.tag.title
			mp3_id3v2_tag.track   = m4a_ref.tag.track
			mp3_id3v2_tag.year    = m4a_ref.tag.year
			mp3_id3v2_tag.comment = "Converted by skomik's awesome Ruby script =)"

			#copying image
			system ("mp4art --extract --art-index 0 -oq \"#{file}\"")
			pic_file_name = file.gsub('.m4a', '')

			Dir["#{pic_file_name}.art*"].each do |pic_file|

				apic = TagLib::ID3v2::AttachedPictureFrame.new
				apic.mime_type = "image/jpeg"
				apic.description = "Cover"
				apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
				apic.picture = File.open(pic_file, 'rb') { |f| f.read }

				mp3_id3v2_tag.add_frame(apic)

				File.delete(pic_file)
			end

			mp3_ref.save
		end
	end

	puts "#{file} succesfully converted".green
end

# to find console utilities
ENV['PATH'] = '/usr/local/bin:/usr/local/sbin:' + ENV['PATH']

file_list = Array.new

if ARGV[0].nil? || Dir.exists?(ARGV[0])
	Dir.chdir(ARGV[0]) unless ARGV[0].nil?
	file_list = Dir["*.m4a"]
else
	Dir.chdir(File.dirname(ARGV[0]))
	ARGV.each do |argument|
		file_list << File.basename(argument)
	end
end

Dir.mkdir('mp3') unless Dir.exists?('mp3')
puts "Working dir: #{Dir.getwd}".blue

work_queue = WorkQueue.new 8, nil
start_time = Time.now

file_list.each do |file|
	work_queue.enqueue_b { process_file(file) }
end

work_queue.join
puts "Time elapsed #{Time.now - start_time} seconds".blue
system("say 'Finished converting in #{(Time.now - start_time).to_i} seconds'")