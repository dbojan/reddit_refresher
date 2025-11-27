program_version='2025-11-15-2
'

#remember to chmod 755 ./refresh.sh if you upload it to your server


for c in curl sed grep xmppc sort stat wc tail lynx jq mpv
do
	if ! command -v $c >/dev/null
	then
		echo $c is missing
	fi
done

alarm="deck.ogg"

#change to script dir
cd "${0%/*}"

###CHANGE THIS
passjabber=""

#vars:
dsp=200
wait_time=60
json_posts_download_limit=25
reddit_history_posts_file="r_reddit_posts_history.txt"
reddit_short_history_comments_file="r_reddit_short_comments_history.txt"
ntfy_chan="https://ntfy.sh/gamesr-github"
ntfy_chan2="https://ntfy.sh/bojang-github"
user_agent="reddit-refresher-github"
custom_feed_url="https://old.reddit.com/user/dbojan76/m/games/new/"
wait_small_time_between_downloads=1
#fav_list="Fatekeeper|Revenge of the Firstborn|greedfall|Warhammer 40.*Dark Heresy|The Expanse.*Osiris Reborn|galaxy.*outlaw|Avowed|Baldur.*s Gate 3|Cyberpunk 2207|Warhammer 40.*Boltgun|Warhammer.*Rogue Trader|hogwarts legacy|solasta|underrail|thaumaturge|Disco Elysium|Detroit.*become Human|No Man.*Sky|Star Wars Battlefront|Star Wars Outlaws|Wasteland 3.*The Battle of Steeltown|Wasteland 3.*colorado|Cult of the Holy Detonation|Clair Obscur.*Expedition 33|Horizon Zero Dawn|The Elder Scrolls IV.*Oblivion Remastered|Tainted Grail.*The Fall of Avalon|Dragon Age.*Veilguard|STAR WARS Jedi.*Survivor|Indiana Jones and the Great Circle|pillars of eternity.*deadfire"
#bigger favorites list for day, and only real hits for night.
favorite_day_var=$(cat favd.txt)
#favorite_night_var=$(cat favn.txt)
#set default variable, will get changed later, depending on the hour
list_with_favorite_games_var="$favorite_day_var"
#don't forget / at the end
#gamedeals excluded.
#allowed_reddits_for_fav_notify="r/IndianGaming/|r/CozyGamers/|r/pcmasterrace/|r/FreeGameGiveaway/|r/playitforward/|r/gog/|r/FREE/|r/Freegamecodes/|r/FreePrimeGaming/|r/GiftofGames/|r/giveawaysforgaming/|r/HumbleBundleKeys/|r/primegaming/|r/RandomActsOfGaming/|r/SteamKeysFreeGiveaway/|r/steam_giveaway/"

#removed
#https://old.reddit.com/r/Freeprimestuff/, no new posts in a year

#sed -e '/\/GiftofGames.*\/request/d' -e '/\/GiftofGames.*\/gog/d' -e '/\/GiftofGames.*\/discussion/d' -e '/\/GiftofGames.*\/intro/d' -e '/\/FreeGameGiveaway.*\/thank_you/d' -e '/\/FreeGameGiveaway.*\/request/d' -e '/\/FreeGameGiveaway.*\/discussion/d'  -e '/\/FREE\/.*website/d' -e '/\/FREE\/.*logo/d'  -e '/\/FREE\/.*app/d'  -e '/\/FREE\/.*ticket/d' -e 's/^r/https:\/\/reddit.com\/r/g' )



reddits_download_not_in_feed_flair_giveaway_only="IndianGaming pcmasterrace CozyGamers raiderking PCGamingDE"
reddits_download_not_in_feed_posts_title_giveaway="Indiangamers pcgaming GiftofGames"

#for reddits not in feed, check if any of them are are in url, if so write extra ntfy.sh with text upfront, used for mark before notify.sh
#join vars
var_together_others_not_in_feed_separated_with_pipe="${reddits_download_not_in_feed_flair_giveaway_only} ${reddits_download_not_in_feed_posts_title_giveaway}"
#replace space with |
var_together_others_not_in_feed_separated_with_pipe="${var_together_others_not_in_feed_separated_with_pipe// /|}"

weekly_gog_url=""
file_weekly_gog="r_weekly_gog_url.txt"

r_bundles="r_bundles.txt"
giveaway_comment="If you wish to give away your extra game keys, please post them under this comment only"
#"Giveaways"


log="r_log.txt"

#mbytes kbytes bytes
#x *kb, 10kb~100 lines
maxsize_history_file=$((40*1024))
#will get divided by this, when reaches max size
divider=2
#for two thirds:
#divider=3*2


#rm -f "$log"

mv "$log" "log 2.txt"
#"$log $(date +%Y_%m_%d-%H_%M_%S).txt"

# echo "removing old file: $reddit_history_posts_file "
# rm -f "$reddit_history_posts_file"


#use with grep -o -E favlist 1.txt


echo "$custom_feed_url, $ntfy_chan, $wait_time , $maxsize_history_file, $json_posts_download_limit ..."

#functions:

fn_log() {
	if [[ -n "$log" ]]; then
		#echo "my_variable exists and is not empty: $my_variable"
		#echo "$(date +%Y_%m_%d-%H_%M_%S)" >> "$log"
		echo "$(date +%Y_%m_%d-%H_%M_%S) $1" >> "$log"
	fi
}

fn_log_file() {
	if [[ -n "$log" ]]; then
		#echo "my_variable exists and is not empty: $my_variable"
		#echo "$(date +%Y_%m_%d-%H_%M_%S)" >> "$log"
		echo "$(date +%Y_%m_%d-%H_%M_%S) log of file $1" >> "$log"
		#echo inside log file
		cat "$1" >> "$log"
	fi
}




fn_fetch_gog_weekly_url_from_web() {
	# Fetch and filter Reddit post
	curl -s -A "$user_agent" "https://www.reddit.com/r/gog/new.json?limit=${json_posts_download_limit}" | \
	  jq -r '.data.children[] 
		| select(.data.link_flair_text == "Giveaway" and (.data.title | ascii_downcase) == "weekly code giveaway thread") 
		| "https://www.reddit.com" + .data.permalink'
}



#data channel
fn_post_to_ntfy_sh() {
	#curl --data-binary "$1" "$2" &
	#replace &amp; with &
	#don't change $2 channel
	local remove_enc="${1/\&amp\;/\&}"
	curl --data-binary "$remove_enc" "$2" &
}


fn_sound_alert_and_post_ntfysh_favorite_found() {
	#data channel
	#send alert
	echo "post to ntfy.sh: ..."
	fn_post_to_ntfy_sh "$1" "$ntfy_chan"
	echo "play on device: ..."
	#mpv "$alarm" &
	#xmppc takes 11 seconds?, sendxmpp is faster but requires perl.
	echo "post to xmpp: ..."
	xmppc --jid dbojankuca@xx --pwd "$passjabber" --mode message chat dbojan@xx "$1" &
	#baresip -f ~/.baresip/ -t 10 -e "/dial dbojan@sip..."
}


#url body
fn_check_if_body_post_is_in_favorites() {
	
	#replace &amp; with &
	local body_of_message="${2/\&amp\;/\&}"
	match_string=""
	match_string=$(echo "$body_of_message" | LC_ALL=C grep -i -o -F -f <(echo "$list_with_favorite_games_var") | sort -u )
	
	#if not empty string, we have favorite match, send alert
	if [ -n "$match_string" ]; then
		#sound the alarm
		echo "$(date +%Y_%m_%d-%H_%M_%S) match_string: $match_string, $1"
		fn_sound_alert_and_post_ntfysh_favorite_found "match $match_string, $1, message start: ${body_of_message:0:$dsp} ..."
		echo -e "MATCH $match_string $1 \n $body_of_message" >> "match fav $(date +%Y_%m_%d-%H_%M_%S).txt"
	else
		echo "not in favorites"
	fi



}


#GOG WEEKLY URL, init, first time
#find weekly gog giveaway thread, first time, if var is empty
if [[ -z "$weekly_gog_url" ]]; then
	#try loading value from file, if file exists
	if [[ -s "$file_weekly_gog" ]]; then
		#echo "File exists and is not empty"
		weekly_gog_url=$(<"$file_weekly_gog")
	else
		#possible fail if started in the middle of the week, and url has floated, then increase var $json_posts_download_limit to 50 or 100
		#else get it from net
		echo "wait $wait_small_time_between_downloads seconds between downloads ..."
		sleep $wait_small_time_between_downloads

		#move to another fn? also done once more, down in code ...
		temp_result_gw=""
		temp_result_gw="$(fn_fetch_gog_weekly_url_from_web)"
		#assign to gw_url, and save it to file
		if [[ -z "$temp_result_gw" || "$temp_result_gw" == "null" ]]; then
			#keep previous value, if there is any
			echo "weekly_gog_url is empty or null"
		else
			weekly_gog_url="$temp_result_gw"
			echo "$temp_result_gw" > "$file_weekly_gog"
		fi
		

	fi
fi




#QUALIFY FOR NTFY.SH
#argument is list of urls as variable
#for reddits which require flair "giveaway" check if it has that flair, or skip line
fn_check_if_it_qualifys_for_ntfy_sh() {

	give_urls=""

	#for each line in url list:
	while IFS= read -r line; do
		echo "check for ntfy, working on $line ..."

		echo "wait $wait_small_time_between_downloads seconds between downloads ..."
		sleep $wait_small_time_between_downloads

		line=${line//https:\/\/reddit/https:\/\/www.reddit}


		json_downloaded=""
		downloaded_reddit_body_as_text_inside_variable=""
		
		#downloaded_reddit_body_as_text_inside_variable=$(lynx -useragent="$user_agent" -dump -nolist -force_html "$line")
		echo "downloading $line in json format ..."
		#remember to ADD .json TO LINE
		json_downloaded=$(curl -s -A "$user_agent" "$line.json")
		flair_downloaded=$(echo "$json_downloaded" | jq -r '.[0].data.children[0].data.link_flair_text // empty')

		created_utc=$(echo "$json_downloaded" | jq -r '.[0].data.children[0].data.created_utc // empty | tonumber | floor')
		now=$(date +%s)
		five_days=$((5 * 24 * 3600))

		if [[ -n "$created_utc" ]] && (( now - created_utc > five_days )); then
			echo "[warning]: $line is older than 5 days, skipping"
			continue
		fi


		##witout title+body:
		#downloaded_reddit_body_as_text_inside_variable=$(echo "$json_downloaded" | jq -r '.[0].data.children[0].data.selftext // empty')
		#add title to body
		downloaded_reddit_body_as_text_inside_variable=$(echo "$json_downloaded" | jq -r '.[0].data.children[0].data | "\(.title)\n\(.selftext // "")"')

		echo "flair_downloaded: $flair_downloaded, body downloaded"

		#cozygamers, pcmasterrace, indian gamers and others from reddit_others: only giveaway flaired posts are already dowloaded, so no need to check them here.
		### these have mostly giveaway, but not always, and they use flairs. not gog, gamebundles, or others
		reddits_which_require_flair="r/primegaming/|r/FreeGameGiveaway/"
		flair_required="Giveaway"

		#check if satisfy for posting to ntfy, this is NOT check for favorites
		#is this reddit that requires specific flair for ntfy.sh?
		#flair has to be downloaded, so two steps?
		if [[ "$line" =~ $reddits_which_require_flair ]]; then
		  	if [[ "$flair_downloaded" != *"$flair_required"* ]]; then
				#echo "Function failed!"
				#move on to the next line in list, skip working with this line. it will not be checked for favs either. it is already added to history_file before this function, so it will not be downloaded again.
				echo "ntfy.sh required flair NOT found in file, skip line "
				continue
			else
				echo "ntfy.sh required flair EXIST in file, work on line "
			fi
		else
			#not either one of the above. no tag needed
			echo "ntfy.sh flair CHECK NOT required"
		fi
		

		#add 'others: ' if not in feed
		if [[ $line =~ $var_together_others_not_in_feed_separated_with_pipe ]]; then
			line="others: $line"
		fi

		if [ -z "$give_urls" ]; then
			give_urls="${line/www.reddit/reddit}"
		else
			#append, with newline between
			give_urls+=$'\n'"${line/www.reddit/reddit}"
		fi

		#url body, post to ntfy all urls later.
		fn_check_if_body_post_is_in_favorites "$line" "$downloaded_reddit_body_as_text_inside_variable"


#do not indent this line
#use < for file, <<< for variable with multiple lines
done <<<  "$1"
	#end done

#if non zero, post all that is left to ntfy.sh
	if [ -n "$give_urls" ]; then
		echo "posting list of new urls to ntfy.sh"
		fn_post_to_ntfy_sh "$give_urls" "$ntfy_chan"
	fi
}


#comment, history
fn_check_if_comment_in_history() {
if grep -q "$1" "$2"; then
  #echo "String found in file."
	return 0
else
  #echo "String not found in file."
	return -1
fi
}



fn_main() {
### MAIN ###  uncomment while ... to run in loop
while true; do

	#-e enable newline interpretation
	#-n do not print newline
	echo -e "\nstart at $(date +%Y_%m_%d-%H_%M_%S) ... "
	fn_log "start at $(date +%Y_%m_%d-%H_%M_%S) ... "
	echo "program version: $program_version"
	#restart script if file q exists
	file_command="r"
	# Check if file_command exists
	if [ -f "$file_command" ]; then
		echo "File '$file_command' exists. restarting script ..."
		rm "$file_command"
		exec "$0" "$@"  # Restart the current script with the same arguments
	fi


	file_command="stop"
	# Check if file_command exists
	if [ -f "$file_command" ]; then
		echo "File '$file_command' exists. stopping ..."
		rm "$file_command"
		exit
	fi


	fn_resize_history

	#always use day, otherwise enable favnightvar at start of script, and if below
	list_with_favorite_games_var="$favorite_day_var"
	
	#which favx to use: From 6 to 22 use favorites_day, otherwise night. From 6 inclusive (6:1, 6:2)  to 21 inclusive (21:1, 21:2 ...)
	#if commented out, favd.txt is set before loop, and used
	#use daytime or nighttime favorites, night favorites are only aaa hits.

	# if [ $(date +%H) -ge 6 ] && [ $(date +%H) -le 21 ]; then
		# list_with_favorite_games_var="$favorite_day_var"
		# echo "hour: $(date +%H), fav name: favorite_day_var"
	# else
		# list_with_favorite_games_var="$favorite_night_var"
		# echo "hour: $(date +%H), fav name: favorite_night_var"
	# fi


	#-s=silent
	#-o=show only matching, -P perl regexp
	#extract post titles; for single op use: curl ... url > output, 2: grep .. pattern ... input > output, 3: sed -e pattern > output (use -i for inline replace, no need her cause output to file)
	#remove lines with unwanted tags
	#and replace /r with https://reddit.com/r
	#1. download file, 2. extract links, 3. remove unwanted tags and replace /r with https... , 4. output to file

	echo "check custom feed $custom_feed_url for changes: download and filter ..."
	#humblebundles have no giveaways anyway, so remove filter: -e '/\/humblebundles.*review/d'


	new_downloaded_links_all_var=$(curl -s -A "$user_agent" "$custom_feed_url" | grep -o -P 'data-permalink=".?\K[^"]*'    |    sed -e '/\/FreeGameGiveaway.*\/thank_you/d' -e '/\/FreeGameGiveaway.*\/request/d' -e '/\/FreeGameGiveaway.*\/discussion/d'  -e '/\/FREE\/.*website/d' -e '/\/FREE\/.*logo/d'  -e '/\/FREE\/.*app/d'  -e '/\/FREE\/.*ticket/d' -e 's/^r/https:\/\/reddit.com\/r/g' )



	fn_download_reddit_posts_flaired_giveaway_not_in_games_feed
	fn_download_reddit_posts_title_giveaway

	echo "all links, feed+new $new_downloaded_links_all_var"


	#(no reddit_history_posts_file)
	if [ ! -f "$reddit_history_posts_file" ]; then
		echo "no old file, send new file with links ... "
		echo "$new_downloaded_links_all_var" >> "$reddit_history_posts_file"
		fn_check_if_it_qualifys_for_ntfy_sh "$new_downloaded_links_all_var"
		#add to list of urls
	else
		#remove file, don't show error if it does not exist
		echo "check for difference ..."
		#find difference:
		#display text in new,that is not in old
		#grep requires arguments to be in the order: first old, THEN new
		text_difference_var=$(echo "$new_downloaded_links_all_var" | LC_ALL=C grep -F -x -v -f "$reddit_history_posts_file" )

		if [ "$text_difference_var" ]; then
			echo "new posts exist, send difference list ... "
			#add JUST DIFFERENCE to list of urls
			echo "$text_difference_var" >> "$reddit_history_posts_file"
			fn_check_if_it_qualifys_for_ntfy_sh "$text_difference_var"
		else
			echo "no difference ..."
		fi

	fi


#download gog, update on mondays, download new top comments, post to ntfy1, not ntfy2, check against favs, uses its own history_comment
fn_gog

#update, check new comments, post new bundles name to ntfy.sh, ntfy sh2;   post new comments to ntfysh1, compare to favs, uses its own history, and history_comment
fn_gamedeals_bundles


echo -e "\nend at $(date +%Y_%m_%d-%H_%M_%S) ... "

### uncoment wait for ... to run in loop, enable either one of those below
echo "wait for $wait_time seconds ...";           sleep $wait_time;                                                              done
#echo "wait for $wait_time seconds ...";           for v in $(seq 1 $wait_time); do echo -n "$v "; sleep 1; done;                 done

#END MAIN

}





fn_gog() {



	###GOG###
	#site r/gog, weekly giveaway thread
	#if Monday and between 10 and 10.05 am ... force update
	if { [[ "$(date +%u)" -eq 1 && "$(date +%H:%M)" > "10:00" && "$(date +%H:%M)" < "10:06" ]]; } || [[ -z "$weekly_gog_url" ]]; then

		echo "wait $wait_small_time_between_downloads seconds between downloads ..."
		sleep $wait_small_time_between_downloads
		temp_result_gw=""
		temp_result_gw="$(fn_fetch_gog_weekly_url_from_web)"
		#assign to gw_url, and save it to file
		if [[ -z "$temp_result_gw" || "$temp_result_gw" == "null" ]]; then
			#keep previous value, if there is any
			echo "weekly_gog_url is empty or null"
		else
			weekly_gog_url="$temp_result_gw"
			echo "$temp_result_gw" > "$file_weekly_gog"
		fi
		
		
	fi
	

	#no way to sort with stickied at top, so over time it will drift away. maybe download 100 posts?
	#weekly_gog_url=https://www.reddit.com/r/gog/comments/1nzd30n/weekly_code_giveaway_thread/
	
	echo "Gog weekly site: $weekly_gog_url"
	
	#if var greater than zero
	if [[ -n "$weekly_gog_url" ]]; then
	
		#echo "GoG Weekly Code Giveaway Thread: $weekly_gog_url"

		echo "wait $wait_small_time_between_downloads seconds between downloads ..."
		sleep $wait_small_time_between_downloads
		echo "check siteA for changes"
		echo "find ids top level comments, if they exist (skip stickied)"
		#remember to add .json to ending
		site1_response=$(curl -s -A "$user_agent" "$weekly_gog_url.json")

		# Extract all top-level, non-stickied comment IDs
		mapfile -t site1_comment_ids < <(echo "$site1_response" | jq -r '
		  .[1].data.children[]
		  | select(.kind == "t1" and (.data.stickied | not))
		  | .data.id')

		echo "siteA url: $weekly_gog_url"		
		echo "siteA ids: ${site1_comment_ids[@]} "
		#fn_log "$weekly_gog_url"

		for site1_new_id in "${site1_comment_ids[@]}"; do
			#if empty or "null" skip
			if [[ -z "$site1_new_id" || "$site1_new_id" == "null" ]]; then
				echo "siteA, comment id: $site1_new_id is empty or jq 'null', skip"
				continue
			fi

			#if in history
			if  $(fn_check_if_comment_in_history "$site1_new_id" "$reddit_short_history_comments_file") ; then
				echo "siteA, comment id: $site1_new_id in history, skip"
				continue
			fi

			#new comment!
			echo "$site1_new_id" >> "$reddit_short_history_comments_file"
			echo "$(date +%Y_%m_%d-%H_%M_%S) new comment detected! in $weekly_gog_url ID: $site1_new_id"

			echo "checking site A new body for favorites"
			#get new_body content
			new_body=""
			new_body=$(echo "$site1_response" | jq -r --arg id "$site1_new_id" '
				.[1].data.children[]
				| select(.kind == "t1" and .data.id == $id)
				| .data.body')

			#use title too for matching. edit no need, title is always gog weekly thread
#			new_body=$(echo "$site1_response" | jq -r --arg id "$site1_new_id" '
#			  {
#				title: .[0].data.children[0].data.title,
#				body: (
#				  .[1].data.children[]
#				  | select(.kind == "t1" and .data.id == $id)
#				  | .data.body
#				)
#			  } | "\(.title)\n\(.body)"')



			echo "site A new_body $new_body"
			fn_post_to_ntfy_sh "new comment: $weekly_gog_url$site1_new_id, message start: ${new_body:0:$dsp} ..." "$ntfy_chan"

			#url body
			fn_check_if_body_post_is_in_favorites "$weekly_gog_url$site1_new_id" "$new_body"

		done
	  
	else
	  echo "No Weekly Code Giveaway Thread found."
	fi


#END GOG

}



fn_gamedeals_bundles() {



	#GAMEDEALS BUNDLES AND FREE
	echo "wait $wait_small_time_between_downloads seconds between downloads ..."; sleep $wait_small_time_between_downloads
	echo "download bundles and free from gamedeals"

	#max old 2 days for download
	#if older than 2 weeks remove from r_bundles list
	# --- Config ---
	now=$(date +%s)
	max_age=$((2 * 24 * 60 * 60))       # 2 days in seconds
	max_age_old=$((14 * 24 * 60 * 60))  # 2 weeks in seconds
	echo "now: $now, max_age: $max_age, max_age_old: $max_age_old"

	# Ensure r_bundles exists
	touch "$r_bundles"

	echo "start gamebundles, not done anything, file r_bundles content:"
	cat "$r_bundles"

	# --- Load existing URLs into associative array ---
	#r_bundles file format:
	#has comment|utc creation time|reddit url
	#0|1761728237.0|https://www.reddit.com/r/GameDeals/comments/1oizfhz/fanatical_the_seance_of_blake_manor_1499_25_off/

declare -A ar_urls_loaded_from_file
url=""
while IFS='|' read -r _ __ url; do
    # 'read' fields: _ (has comment), __ (time), url (the actual URL)
    # The first two variables (_ and __) are "throwaway" placeholders.
    
    # 2. Add the URL as the KEY to the associative array
    # The value (e.g., '1') doesn't matter much since you only care about the key's existence.
    ar_urls_loaded_from_file["$url"]=1 
    
done < "$r_bundles"


	 echo "print ar_urls_loaded_from_file" 
	 for key in "${!ar_urls_loaded_from_file[@]}"; do
		 echo "Key: $key, Value: ${ar_urls_loaded_from_file[$key]}"
	 done



	# --- Download new posts ---
	new_post=""
	new_posts=$(curl -s -A "$user_agent" \
  "https://www.reddit.com/r/GameDeals/new.json?limit=${json_posts_download_limit}" | \
  jq -r --argjson now "$now" --argjson max_age "$max_age" '
    .data.children[]
    | select(type == "object")
    | select(
        (.data.created_utc | numbers) > ($now - $max_age)
        and
        (
          (.data.title // "") | test("^\\[humble"; "i")
          or test("^\\[gmg"; "i")
          or test("^\\[amazon"; "i")
          or test("^\\[prime"; "i")
          or test("^\\[fanatical"; "i")
          or test("^\\[planetplay"; "i")
          or test("^\\[digiphile"; "i")
          or test("100%"; "i")
        )
      )
    | "\(.data.created_utc)|https://www.reddit.com\(.data.permalink)"'
)
	#last ( is from $(curl

	echo "array new gamebundle posts downloaded new posts=$new_posts"

	if [[ -z "$new_posts" || "$new_posts" == "null" ]]; then
		echo "no new posts, skip this iteration"
		#continue
	else


		url=""
		while IFS='|' read -r st_utc_time_created url; do

			echo "inside while, checking if url = $url already in file r_bundles=seen url"

			# Skip if URL already seen, if $url exists in array, SKIP if url does not exist
			if [[ -v ar_urls_loaded_from_file["$url"] || "$url" == "null" || -z "$url" ]]; then
				echo "YES, Already seen: $url, skip this iteration"
				continue
			else
				echo "gamedeals new url NOT seen before: $url"
				fn_post_to_ntfy_sh "gamedeals: $url" "$ntfy_chan"
				#fn_post_to_ntfy_sh "gamedeals: $url" "$ntfy_chan2"
			fi

			post_id=$(echo "$url" | awk -F'/' '{print $7}')

			echo "wait $wait_small_time_between_downloads seconds between downloads ..."; sleep $wait_small_time_between_downloads
			echo "--- DOWNLOADING comments for $url"

			comments_json=""
			comments_json=$(curl -s -A "$user_agent" "https://www.reddit.com/comments/${post_id}.json")

			if [[ -z "$comments_json" || "$comments_json" == "null" ]]; then
			#echo "comments: $comments_json"
				echo "no comments, skip this iteration"
				continue
			fi

			#keep working...
			
			first_stickied_text=""
			#return match found if matches, limit search to first match stickied
			first_stickied_text=$(echo "$comments_json" | jq -r --arg needed "$giveaway_comment" '
			  limit(1;
				.[1].data.children[]
				| select(.data.stickied == true)
				| .data.body
				| select(test($needed; "i"))
				| "match found"
			  )
			')

			# # --- Extract first stickied comment that matches the needed text safely ---
			# first_stickied_text=$(echo "$comments_json" | jq -r --arg needed "$giveaway_comment" '
			# .[1].data.children[]
			# | select(.data.stickied == true)
			# | .data.body
			# | select(test($needed; "i"))
			# ' | head -n 1)

			echo "for $url: First stickied text=$first_stickied_text"

			# --- Determine if the needed comment exists ---

			if [[ -z "$first_stickied_text" || "$first_stickied_text" == "null" ]]; then
				echo "stickied tex is empty or null, bo is 0"
				bo_has_comment=0
			else
				bo_has_comment=1
			fi

			# if [[ -n "$first_stickied_text" ]]; then
			#  bo_has_comment=1
			# else
			#  bo_has_comment=0
			# fi

			echo "comment: $first_stickied_text, boolean has comment: _${bo_has_comment}_"
			echo "appending to r_bundle this: $bo_has_comment|$st_utc_time_created|$url"

			# --- Append post info to r_bundles ---
			echo "$bo_has_comment|$st_utc_time_created|$url" >> "$r_bundles"

			# --- Mark this URL as seen ---, 1 is dummy, just anything would do.

			if [[ -n "$url" ]]; then
			   ar_urls_loaded_from_file["$url"]=1
			else
			  fn_log "++++++++++++++++++warning url var is empty. url=$url, sticky comment=$first_stickied_text"
			fi

done <<< "$new_posts"
	fi




	echo "gamebundles: file r_bundles content, after appending new posts"
	cat "$r_bundles"

	# --- Remove old entries older than 2 weeks ---
	echo "# --- Remove old entries older than 2 weeks ---"
	awk -F'|' -v now="$now" -v max_age_old="$max_age_old" '$2 >= (now - max_age_old)' "$r_bundles" > "${r_bundles}.tmp"
	mv "${r_bundles}.tmp" "$r_bundles"

	# --- Build array of URLs with bo_has_comment=1 using mapfile ---
	echo "# --- Build array of URLs with bo_has_comment=1 ---"
	mapfile -t ar_bundles < <(awk -F'|' '$1 == 1 {print $3}' "$r_bundles" | sort -u)


	echo "removed old gamebundles, file r_bundles content:"
	cat "$r_bundles"



	# --- Echo results ---
	#printf "bundles with 1 in comment, will check for giveaway comments: %s\n" "${ar_bundles[@]}"

	echo "out of while, checking bundles for comments"



	###Check gamebundles for new comment, when type is giveaway
	#site gamedeals bundle latest: fanatical, humble, prime check for new posts, AND if in FAVS
	#going through sorted by date?
	for site1_url in "${ar_bundles[@]}"; do
	 
		echo "wait $wait_small_time_between_downloads seconds between downloads ..."
		sleep $wait_small_time_between_downloads
		echo "gamebundles: find ids of new replies, if they exist"

		#site1_url="https://www.reddit.com/r/GameDeals/comments/1nlc5a7/humble_remedy_games_30th_anniversary_bundle_5_for/"

		# Get JSON response
		site1_response=$(curl -s "$site1_url.json" -A "$user_agent")

		#echo "site1 response: $site1_response"
		

		echo "check if post deleted/removed from site: $site1_url"
		selftext=""
		selftext=$(echo "$site1_response" | jq -r '.[0].data.children[0].data.selftext' 2>/dev/null)

		# Check for removal conditions
		if [[ "$selftext" == "[removed]" || "$selftext" == "[deleted]" ]]; then
			echo "Post [DELETED] $site1_url â€” deleting from bundle, skip checking"
			grep -vF "$site1_url" "$r_bundles" > "${r_bundles}.tmp" && mv "${r_bundles}.tmp" "$r_bundles"
			continue
		else
			echo "Post [OK] $site1_url still available, keep working"
		fi
		echo "selftext: ${selftext:0:50}"


		echo "Extract all direct replies to stickied comment(s), no sorting"

		mapfile -t site1_comment_ids < <(echo "$site1_response" | jq -r '
		  .[1].data.children[]
		  | select(.data.stickied == true and (.data.replies | type == "object"))
		  | .data.replies.data.children[]
		  | if .kind == "t1" then .data.id
		    elif .kind == "more" and (.data.children | length > 0) then .data.children[]
		    else empty
		    end
		')
		
		echo "siteB url: $site1_url" 
		echo "siteB ids: ${site1_comment_ids[@]}"

		for site1_new_id in "${site1_comment_ids[@]}"; do

			#if empty or "null" skip
			if [[ -z "$site1_new_id" || "$site1_new_id" == "null" ]]; then
				echo "siteB, comment id: $site1_new_id is empty or jq 'null', skip"
				continue
			fi
			#if in history
			if  $(fn_check_if_comment_in_history "$site1_new_id" "$reddit_short_history_comments_file") ; then
				echo "siteB comment id: $site1_new_id in history, skip"
				continue
			fi

			#new comment!
			echo "$site1_new_id" >> "$reddit_short_history_comments_file"
			echo "$(date +%Y_%m_%d-%H_%M_%S) new comment detected! in $site1_url ID: $site1_new_id"

			#get body, have to download json of the comment
			echo "wait $wait_small_time_between_downloads seconds between downloads ..."
			sleep $wait_small_time_between_downloads
			echo "checking B body for favorites"
			site1_more_response=$(curl -s "https://www.reddit.com/api/info.json?id=t1_${site1_new_id}" -A "$user_agent")
			new_body=""
			new_body=$(echo "$site1_more_response" | jq -r '.data.children[0].data.body')
			#use title too, for matching. edit title is always the same, name of bundle ...
			#new_body=$(echo "$site1_more_response" | jq -r '"\(.data.children[0].data.title)\n\(.data.children[0].data.body)"')

			echo "site B new_body $new_body"

			fn_post_to_ntfy_sh "new comment: $site1_url$site1_new_id, message start: ${new_body:0:$dsp} ..." "$ntfy_chan"

			#url body
			fn_check_if_body_post_is_in_favorites "$site1_url$site1_new_id" "$new_body"

		done

	done
#END GAMEBUNDLES

}




fn_download_reddit_posts_title_giveaway() {


    # Not part of gamefeeds, but sometimes have giveaways.
    # Match posts where the title includes 'giveaway' or 'giving away' (case-insensitive).
	#address is reddit.com, not www.reddit, change later if needed
	##USE DOUBLE ESCAPES IN jq for [

    for outr in $reddits_download_not_in_feed_posts_title_giveaway
    do
        echo "Download giveaways from $outr, using https://www.reddit.com/r/${outr}/new.json?limit=${json_posts_download_limit}"
        echo "Wait $wait_small_time_between_downloads seconds between downloads..."
        sleep $wait_small_time_between_downloads

        list_urls=$(curl -s "https://www.reddit.com/r/${outr}/new.json?limit=${json_posts_download_limit}" -A "$user_agent" \
        | jq -r '.data.children[]
            | select(.data.title | test("(?i)(giveaway|giving away|\\[offer\\])"))
            | "https://reddit.com" + .data.permalink')

        echo "NEW $outr links: $list_urls"

# DO NOT INDENT
        new_downloaded_links_all_var="${new_downloaded_links_all_var}
${list_urls}"

    done
}




fn_download_reddit_posts_flaired_giveaway_not_in_games_feed() {


	#not part of gamefeeds, but sometimes have giveaways. most of the times they do not, only with flair matching 'giveaways'
	#"r/CozyGamers/" "r/pcmasterrace/" , indiangamers
	#address is reddit.com, not www.reddit, change later if needed
	for outr in $reddits_download_not_in_feed_flair_giveaway_only
	do
		echo "download giveaways $outr, using https://www.reddit.com/r/${outr}/new.json?limit=${json_posts_download_limit}"
		echo "wait $wait_small_time_between_downloads seconds between downloads ..."; sleep $wait_small_time_between_downloads
		#use 'test' to match anything Giveaway, not strict matching
		list_urls=$(curl -s "https://www.reddit.com/r/${outr}/new.json?limit=${json_posts_download_limit}" -A "$user_agent" \
		|jq -r '.data.children[]
		| select(.data.link_flair_text | test("Giveaway"; "i"))
		| "https://reddit.com" + .data.permalink')

		echo "NEW $outr links: $list_urls"

#DO NOT INDENT
	new_downloaded_links_all_var="${new_downloaded_links_all_var}
${list_urls}"

	done

}


fn_resize_history() {

	#RESIZE HISTORY posts
	#first check if file exist and is greater size than 0
	if [ -s "$reddit_history_posts_file" ]; then
		if [ $(stat -c %s "$reddit_history_posts_file") -gt $maxsize_history_file ]; then
			#echo "$num1 is greater than $num2"
			echo "$(date +%Y_%m_%d-%H_%M_%S): $reddit_history_posts_file is bigger than $maxsize_history_file, halving it ... "
			fn_log "$(date +%Y_%m_%d-%H_%M_%S): $reddit_history_posts_file too large, resizing it, old size: $(stat -c %s $reddit_history_posts_file) bytes ..."
			#cp "$reddit_history_posts_file" "$reddit_history_posts_file $(date +%Y_%m_%d-%H_%M_%S) full.txt"
			total_lines=$(wc -l < "$reddit_history_posts_file")
			#-n keep lastn lines. use /2=half, or /3*2=60 percent
			lines_to_keep=$((total_lines / $divider)) # Integer division for simplicity

			# Use tail to get the last 'lines_to_keep' lines and overwrite the original file
			tail -n "$lines_to_keep" "$reddit_history_posts_file" > temp_file && mv temp_file "$reddit_history_posts_file"
			fn_log "$(date +%Y_%m_%d-%H_%M_%S): $reddit_history_posts_file new size $(stat -c %s $reddit_history_posts_file) bytes ..."
			#cp "$reddit_history_posts_file" "$reddit_history_posts_file $(date +%Y_%m_%d-%H_%M_%S) halved.txt"

		fi
	fi



	#RESIZE HISTORY comments
	#first check if file exist and is greater size than 0, limit is maxsize_history_file/4
	if [ -s "$reddit_short_history_comments_file" ]; then
		if [ $(stat -c %s "$reddit_short_history_comments_file") -gt  $(($maxsize_history_file / 4 ))   ]; then
			#echo "$num1 is greater than $num2"
			echo "$(date +%Y_%m_%d-%H_%M_%S): $reddit_short_history_comments_file is bigger than $maxsize_history_file / 4 , halving it ... "
			fn_log "$(date +%Y_%m_%d-%H_%M_%S): $reddit_short_history_comments_file too large, resizing it, old size: $(stat -c %s $reddit_short_history_comments_file) bytes ..."
			#cp "$reddit_short_history_comments_file" "$reddit_short_history_comments_file $(date +%Y_%m_%d-%H_%M_%S) full.txt"
			total_lines=$(wc -l < "$reddit_short_history_comments_file")
			#-n keep lastn lines. use /2=half, or /3*2=60 percent
			lines_to_keep=$((total_lines / $divider)) # Integer division for simplicity

			# Use tail to get the last 'lines_to_keep' lines and overwrite the original file
			tail -n "$lines_to_keep" "$reddit_short_history_comments_file" > temp_file && mv temp_file "$reddit_short_history_comments_file"
			fn_log "$(date +%Y_%m_%d-%H_%M_%S): $reddit_short_history_comments_file new size $(stat -c %s $reddit_short_history_comments_file) bytes ..."
			#cp "$reddit_short_history_comments_file" "$reddit_short_history_comments_file $(date +%Y_%m_%d-%H_%M_%S) halved.txt"

		fi
	fi





}







fn_main

#FOR SIP:
#install baresip
#edit ~/.baresip/accounts, enable line: <sip:yourusernameher@sip.linphone.org>;auth_pass=yourpasshere
#on Android, use sipdroid or something; enable app run in background,
#if downloaded file has text, then sip call, else do not call
#WARNING VAR SUBSTITION DOES NOT WORK FROM CRON. run it as * * * * * bash -l /home/b/script.sh
#baresip is currently unavailabe on termux :( 2025-09

#FOR XMPP MESSAGE:
#install dino or some other client on pc
#register account on jabber.fr
#install xmppc on termux (sendxmpp is also available, untested)

#for xmppc, create config file, as per https://www.mankier.com/1/xmppc:
#mkdir ~/.config
#touch ~/.config/xmppc.conf
#chmod ~/.config/xmppc.conf 755


#sendxmpp requiers perl, on termux it is a long install ...

#use termux-storage + 'material files' + chmod 755 r
#to run type: termux-wake-lock, then type ./t

#for audio file play, install mpv
