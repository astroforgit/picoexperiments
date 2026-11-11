; League menus and season logic, mapped at $C000 from VRAM $71000.
; MEMAC-B bank $9E holds rosters at $5000 and season state at $7000.
        icl 'vars.asm'
        icl '../gen/rt-labels.asm'
        org $7000
season_team .ds 1
season_round .ds 1
season_live .ds 1
menu_page .ds 1
selection .ds 1
pick_mode .ds 1
squad_team .ds 1
fixture_round .ds 1
home_team .ds 1
away_team .ds 1
next_fixture .ds 1
home_score .ds 1
away_score .ds 1
random_seed .ds 1
last_input .ds 1
row .ds 1
list_index .ds 1
team_index .ds 1
fixture_index .ds 1
rank_index .ds 1
candidate .ds 1
player_slot .ds 1
scorer_index .ds 1
scorer_lo .ds 1
scorer_hi .ds 1
number_lo .ds 1
number_hi .ds 1
temp .ds 1
result_home .ds 56
result_away .ds 56
points .ds 8
wins .ds 8
draws .ds 8
losses .ds 8
gf_lo .ds 8
gf_hi .ds 8
gd_lo .ds 8
gd_hi .ds 8
ranking .ds 8
player_goals_lo .ds 128
player_goals_hi .ds 128
pitch_choice .ds 1      ; zero is random, 1-7 are the original pitches
length_choice .ds 1
option_row .ds 1
escape_held .ds 1
hub_choice .ds 1
confirm_choice .ds 1
        ert * > LEAGUE_MATCH_SCORERS

dst = $20
source = $22
name_ptr = $24
compare_lo = $26
compare_hi = $27
text_screen = $7800

        org $c000
league_main
        cld
        lda #$9e
        jsr MEMB
        lda #$1f
        sta escape_held
        sta last_input           ; require a fresh press after a match
        lda league_return
        beq show_page
        lda #0
        sta league_return
        lda league_goals
        sta home_score
        lda league_goals+1
        sta away_score
        lda league_match
        cmp #1
        bne friendly_return
        jsr credit_played_goals
        jsr complete_round
        lda #5
        bne match_return
friendly_return
        lda #6
match_return
        sta menu_page
        lda #0
        sta league_match
show_page
        lda match_abort
        beq abort_done
        lda #0
        sta match_abort
        sta menu_page
        sta selection
abort_done
        lda #$ff
        sta league_art_id
        jsr clear_screen
        lda #1
        sta row

        lda menu_page
        asl
        tax
        lda pages,x
        sta page_call+1
        lda pages+1,x
        sta page_call+2
page_call
        jsr $ffff
        lda #23
        sta row
        ldx #3
        lda #<escape_help
        ldy #>escape_help
        jsr print_at
        lda #3
        jsr colour_row
        jsr LEAGUE_DRAW
menu_wait
        lda frames
menu_vbi
        cmp frames
        beq menu_vbi
        lda $d20f
        and #4
        bne escape_release
        lda $d209
        and #$3f
        cmp #28
        bne escape_release
        lda escape_held
        bne menu_wait
        inc escape_held
        jsr parent_menu
        jmp show_page
escape_release
        lda #0
        sta escape_held
        lda joy1
        eor #$1f
        and #$1f
        tax
        eor last_input
        stx last_input
        and last_input
        beq menu_wait
        pha
        lda menu_page
        asl
        tax
        lda actions,x
        sta action_call+1
        lda actions+1,x
        sta action_call+2
        pla
action_call
        jsr $ffff
        jmp show_page

pages   dta a(home_page,pick_page,table_page,squad_page,fixtures_page,results_page,friendly_result,options_page,hub_page,confirm_page)
actions dta a(home_action,pick_action,table_action,squad_action,fixtures_action,results_action,home_return,options_action,hub_action,confirm_action)

home_page
        lda selection
        sta league_art_id
        lda #6
        sta row
        lda #0
        sta list_index
home_line
        ldx list_index
        lda home_lo,x
        ldy home_hi,x
        ldx #3
        jsr print_at
        lda list_index
        cmp selection
        bne home_next
        jsr highlight
home_next
        inc row
        inc row
        inc list_index
        lda list_index
        cmp #4
        bcc home_line
        lda season_live
        bne home_help
        lda selection
        cmp #2
        bne home_help
        lda #16
        sta row
        ldx #3
        lda #<no_season
        ldy #>no_season
        jsr print_at
home_help
        lda menu_page
        bne help_controls
        lda #21
        sta row
        ldx selection
        lda help_lo,x
        ldy help_hi,x
        ldx #3
        jsr print_at
help_controls
        lda #22
        sta row
        ldx #3
        lda #<pick_help
        ldy #>pick_help
        jmp print_at
home_action
        bit fire_mask
        bne home_fire
        ldx #4
        jmp move_selection
home_fire
        lda selection
        cmp #1
        beq open_classic
        cmp #3
        beq open_options
        cmp #2
        bne begin_picker
        lda season_live
        beq action_done
        lda #8
        sta menu_page
action_done
        rts
open_classic
        lda #0
        sta $92b7
        sta league_match
        lda #1
        sta $92c2
        jmp LEAGUE_LAUNCH
open_options
        lda #0
        sta option_row
        lda #7
        sta menu_page
        rts
begin_picker
        sta pick_mode
        lda #0
        sta selection
        lda #1
        sta menu_page
        rts

pick_page
        lda #4
        sta row
        ldx #3
        lda #<choose_club
        ldy #>choose_club
        jsr print_at
        lda pick_mode
        cmp #2
        bne pick_list
        ldx #3
        lda #<choose_away
        ldy #>choose_away
        jsr print_at
pick_list
        lda #6
        sta row
        lda #0
        sta list_index
pick_line
        ldy list_index
        ldx #5
        jsr print_club
        lda list_index
        cmp selection
        bne pick_next
        jsr highlight
pick_next
        inc row
        inc list_index
        lda list_index
        cmp #8
        bcc pick_line
        jmp home_help

pick_action
        bit fire_mask
        bne pick_fire
        and #4
        jne home_return
        lda last_input
        ldx #8
        jmp move_selection
pick_fire
        lda pick_mode
        bne pick_friendly
        lda season_live
        beq new_season
        lda #0
        sta confirm_choice
        lda #9
        sta menu_page
        rts
new_season
        lda selection
        sta season_team
        lda #0
        ldx #(player_goals_lo-result_home)-1
reset_table
        sta result_home,x
        dex
        cpx #$ff
        bne reset_table
        ldx #127
reset_goals
        sta player_goals_lo,x
        sta player_goals_hi,x
        dex
        bpl reset_goals
        sta season_round
        lda #$a7
        sta random_seed
        lda #1
        sta season_live
        lda #0
        sta hub_choice
        lda #8
        sta menu_page
        rts
pick_friendly
        cmp #2
        beq pick_opponent
        lda selection
        sta home_team
        lda #2
        sta pick_mode
        inc selection
        lda selection
        and #7
        sta selection
        rts
pick_opponent
        lda selection
        cmp home_team
        jeq action_done
        sta away_team
        lda #2
        jmp start_match

home_return
        lda #0
        sta menu_page
        sta selection
        rts

parent_menu
        lda menu_page
        cmp #9
        bne parent_normal
cancel_new
        lda #8
        sta menu_page
        rts
parent_normal
        cmp #1
        bne parent_league
        lda pick_mode
        cmp #2
        bne parent_home
        dec pick_mode
        lda home_team
        sta selection
        rts
parent_league
        cmp #2
        bcc parent_home
        cmp #6
        bcs parent_home
        lda #8
        sta menu_page
        rts
parent_home
        jmp home_return

hub_page
        lda #2
        sta league_art_id
        lda #3
        sta row
        ldy season_team
        ldx #3
        jsr print_club
        lda #6
        sta row
        lda #0
        sta list_index
hub_line
        ldx list_index
        cpx #0
        bne hub_label
        lda season_round
        cmp #14
        bcc hub_label
        lda #<finished_label
        ldy #>finished_label
        bne hub_print
hub_label
        lda hub_lo,x
        ldy hub_hi,x
hub_print
        ldx #5
        jsr print_at
        lda list_index
        cmp hub_choice
        bne hub_next
        jsr highlight
hub_next
        inc row
        inc row
        inc list_index
        lda list_index
        cmp #6
        bcc hub_line
        jmp home_help
hub_action
        bit fire_mask
        bne hub_fire
        ldx selection
        stx temp
        ldx hub_choice
        stx selection
        ldx #6
        jsr move_selection
        lda selection
        sta hub_choice
        lda temp
        sta selection
        rts
hub_fire
        ldx hub_choice
        beq hub_play
        lda hub_pages,x
        sta menu_page
        lda season_team
        sta squad_team
        lda season_round
        cmp #14
        bcc hub_round
        lda #13
hub_round
        sta fixture_round
        cpx #4
        bne hub_done
        lda season_round
        bne hub_done
        lda #4
        sta menu_page
hub_done
        rts
hub_play
        lda season_round
        cmp #14
        jcs dashboard_return
        jsr find_fixture
        lda #1
        jmp start_match
confirm_page
        lda #7
        sta row
        ldx #3
        lda #<confirm_text
        ldy #>confirm_text
        jsr print_at
        lda #10
        sta row
        ldx #3
        lda #<confirm_cancel
        ldy #>confirm_cancel
        jsr print_at
        lda #12
        sta row
        ldx #3
        lda #<confirm_yes
        ldy #>confirm_yes
        jsr print_at
        lda confirm_choice
        asl
        clc
        adc #10
        sta row
        jmp highlight
confirm_action
        bit fire_mask
        beq confirm_move
        lda confirm_choice
        jeq cancel_new
        jmp new_season
confirm_move
        and #3
        beq confirm_done
        lda confirm_choice
        eor #1
        sta confirm_choice
confirm_done
        rts
confirm_text dta c'REPLACE SEASON AND DELETE RESULTS',0
confirm_cancel dta c'CANCEL  KEEP CURRENT LEAGUE',0
confirm_yes dta c'YES  START NEW LEAGUE',0
hub_pages dta 2,2,3,4,5,0
hub_lo dta <play_label,<standings_label,<squad_label,<schedule_label,<scores_label,<back_label
hub_hi dta >play_label,>standings_label,>squad_label,>schedule_label,>scores_label,>back_label
play_label dta c'PLAY NEXT MATCH',0
standings_label dta c'LEAGUE TABLE',0
squad_label dta c'VIEW SQUADS',0
schedule_label dta c'MATCH SCHEDULE',0
scores_label dta c'LAST RESULTS',0
back_label dta c'MAIN MENU',0

; Up/down moves among the X choices.
move_selection
        lsr
        bcc move_down
        lda selection
        bne selection_dec
        stx selection
selection_dec
        dec selection
        rts
move_down
        and #1
        jeq action_done
        inc selection
        cpx selection
        jne action_done
        lda #0
        sta selection
        rts

table_page
        jsr sort_table
        lda #3
        sta row
        ldx #3
        lda #<table_header
        ldy #>table_header
        jsr print_at
        lda #3
        jsr colour_row
        lda #0
        sta list_index
        lda #5
        sta row
table_line
        ldx list_index
        lda ranking,x
        sta team_index
        tay
        ldx #3
        jsr print_club
        ldx team_index
        lda wins,x
        ldx #25
        jsr number_at
        ldx team_index
        lda draws,x
        ldx #28
        jsr number_at
        ldx team_index
        lda losses,x
        ldx #31
        jsr number_at
        ldx team_index
        lda points,x
        ldx #35
        jsr number_at
        lda team_index
        cmp season_team
        bne table_next
        jsr highlight
table_next
        inc row
        inc list_index
        lda list_index
        cmp #8
        bcc table_line
        lda #15
        sta row
        lda season_round
        cmp #14
        bcc next_match_line
        ldx ranking
        ldy ranking+1
        jsr compare_teams
        beq joint_title
        ldx #3
        lda #<champion_label
        ldy #>champion_label
        jsr print_at
        ldy ranking
        ldx #13
        jsr print_club
        jmp table_footer
joint_title
        ldx #3
        lda #<joint_label
        ldy #>joint_label
        jsr print_at
        jmp table_footer
next_match_line
        jsr find_fixture
        ldx #3
        lda #<round_label
        ldy #>round_label
        jsr print_at
        lda season_round
        clc
        adc #1
        ldx #9
        jsr number_at
        inc row
        ldy home_team
        ldx #3
        jsr print_club
        inc row
        ldy away_team
        ldx #3
        jsr print_club
table_footer
        jsr top_scorer
        lda #21
        sta row
        ldx #3
        lda #<table_help
        ldy #>table_help
        jsr print_at
        inc row
        ldx #3
        lda #<table_help2
        ldy #>table_help2
        jmp print_at

table_action
        bit fire_mask
        jne dashboard_return
        rts

squad_page
        lda #3
        sta row
        ldy squad_team
        ldx #4
        jsr print_club
        lda #5
        sta row
        ldx #4
        lda #<starting_label
        ldy #>starting_label
        jsr print_at
        lda #3
        jsr colour_row
        inc row
        lda #0
        sta list_index
squad_line
        lda list_index
        cmp #11
        bne squad_name
        ldx #4
        lda #<reserve_label
        ldy #>reserve_label
        jsr print_at
        lda #3
        jsr colour_row
        inc row
squad_name
        lda list_index
        clc
        adc #1
        ldx #4
        jsr number_at
        ldy squad_team
        jsr roster_pointer
        ldx list_index
squad_offset
        jsr advance_name
        dex
        bpl squad_offset
        ldx #8
        jsr print_name
        inc row
        inc list_index
        lda list_index
        cmp #16
        bcc squad_line
        lda #4
        sta row
        ldx #3
        lda #<squad_help
        ldy #>squad_help
        jmp print_at

squad_action
        bit fire_mask
        bne dashboard_return
        and #12
        beq dashboard_done
        and #4
        beq squad_next
        dec squad_team
        jmp squad_wrap
squad_next
        inc squad_team
squad_wrap
        lda squad_team
        and #7
        sta squad_team
dashboard_done
        rts

dashboard_return
        lda #8
        sta menu_page
        rts

results_page
        lda season_round
        sec
        sbc #1
        sta fixture_round
        jmp fixtures_page

fixtures_page
        lda #4
        sta row
        lda #<round_label
        ldy #>round_label
        ldx #3
        jsr print_at
        lda fixture_round
        clc
        adc #1
        ldx #9
        jsr number_at
        lda fixture_round
        asl
        asl
        sta fixture_index
        lda #7
        sta row
fixture_line
        ldx fixture_index
        ldy fixture_home,x
        ldx #3
        jsr print_club
        lda fixture_round
        cmp season_round
        bcs fixture_away_line
        ldx fixture_index
        lda result_home,x
        ldx #29
        jsr number_at
fixture_away_line
        inc row
        ldx fixture_index
        ldy fixture_away,x
        ldx #3
        jsr print_club
        lda fixture_round
        cmp season_round
        bcs fixture_no_score
        ldx fixture_index
        lda result_away,x
        ldx #29
        jsr number_at
fixture_no_score
        inc row
        inc row
        inc fixture_index
        lda fixture_index
        and #3
        bne fixture_line
        lda #21
        sta row
        ldx #3
        lda menu_page
        cmp #5
        bne all_fixtures_help
        lda #<result_help
        ldy #>result_help
        jmp print_at
all_fixtures_help
        lda #<fixtures_help
        ldy #>fixtures_help
        jmp print_at

fixtures_action
        bit fire_mask
        jne dashboard_return
        and #4
        beq fixtures_next
        lda fixture_round
        beq fixtures_done
        dec fixture_round
        rts
fixtures_next
        lda fixture_round
        cmp #13
        bcs fixtures_done
        inc fixture_round
fixtures_done
        rts

results_action
        bit fire_mask
        jne dashboard_return
        rts

friendly_result
        lda #6
        sta row
        ldy home_team
        ldx #3
        jsr print_club
        lda home_score
        ldx #30
        jsr number_at
        inc row
        inc row
        ldy away_team
        ldx #3
        jsr print_club
        lda away_score
        ldx #30
        jsr number_at
        lda #20
        sta row
        ldx #3
        lda #<return_help
        ldy #>return_help
        jmp print_at

options_page
        lda #5
        sta league_art_id
        lda #6
        sta row
        ldx #5
        lda #<pitch_label
        ldy #>pitch_label
        jsr print_at
        inc row
        ldx pitch_choice
        lda pitch_lo,x
        ldy pitch_hi,x
        ldx #5
        jsr print_at
        lda option_row
        bne option_length
        jsr highlight
option_length
        lda #10
        sta row
        ldx #5
        lda #<length_label
        ldy #>length_label
        jsr print_at
        inc row
        ldx length_choice
        lda length_lo,x
        ldy length_hi,x
        ldx #5
        jsr print_at
        lda option_row
        beq options_footer
        jsr highlight
options_footer
        lda #20
        sta row
        ldx #3
        lda #<option_help
        ldy #>option_help
        jmp print_at

options_action
        bit fire_mask
        beq option_move
        lda #3
        sta selection
        lda #0
        sta menu_page
        rts
option_move
        bit vertical_mask
        beq option_change
        lda option_row
        eor #1
        sta option_row
        rts
option_change
        and #12
        beq option_done
        and #4
        beq option_increase
        lda #$ff
        bne option_apply
option_increase
        lda #1
option_apply
        ldx option_row
        bne change_length
        clc
        adc pitch_choice
        and #7
        sta pitch_choice
        rts
change_length
        clc
        adc length_choice
        and #3
        sta length_choice
option_done
        rts


find_fixture
        lda season_round
        asl
        asl
        tax
find_next
        lda fixture_home,x
        cmp season_team
        beq fixture_found
        lda fixture_away,x
        cmp season_team
        beq fixture_found
        inx
        bne find_next
fixture_found
        stx next_fixture
        lda fixture_home,x
        sta home_team
        lda fixture_away,x
        sta away_team
        rts

start_match
        sta league_match
        lda #0
        ldx #21
reset_scorers
        sta LEAGUE_MATCH_SCORERS,x
        dex
        bpl reset_scorers
        lda #0
        sta league_cfg          ; friendly engine rules allow draws
        sta league_cfg+3        ; player 1 controls home unless playing away
        lda length_choice
        sta league_cfg+2
        lda pitch_choice
        sec
        sbc #1
        and #7
        sta league_cfg+1
        lda #4
        sta league_cfg+6        ; normal strength
        lda #1
        sta league_cfg+7        ; away CPU
        lda league_match
        cmp #1
        bne match_kits
        lda away_team
        cmp season_team
        bne match_kits
        lda #1
        sta league_cfg+3        ; home CPU
        lda #0
        sta league_cfg+7        ; away human (resident bridge routes joystick 1)
match_kits
        ldx home_team
        lda club_formation,x
        sta league_cfg+4
        lda club_shirt,x
        sta league_cfg+5
        ldx away_team
        lda club_formation,x
        sta league_away_formation
        lda club_shirt,x
        sta league_away_shirt
        jmp LEAGUE_LAUNCH

; Commit the played fixture and the other three fixtures in the same round.
; The resident return flag is consumed before this runs, so revisiting a
; result screen can never add points or roll a second result.
complete_round
        lda season_round
        asl
        asl
        sta fixture_index
commit_fixture
        ldx fixture_index
        cpx next_fixture
        bne simulate_fixture
        lda home_score
        sta result_home,x
        lda away_score
        jmp store_away
simulate_fixture
        jsr simulated_goals
        sta result_home,x
        jsr simulated_goals
store_away
        sta result_away,x
        cpx next_fixture
        beq fixture_points
        lda result_home,x
        ldy fixture_home,x
        jsr credit_simulated
        ldx fixture_index
        lda result_away,x
        ldy fixture_away,x
        jsr credit_simulated
fixture_points
        ldx fixture_index
        jsr add_result
        inc fixture_index
        lda fixture_index
        and #3
        bne commit_fixture
        inc season_round
        rts

simulated_goals
        jsr roll_random
        and #7
        tay
        lda goal_distribution,y
        rts
roll_random
        lda random_seed
        lsr
        bcc seed_ready
        eor #$b8
seed_ready
        sta random_seed
        rts
goal_distribution dta 0,0,1,1,1,2,2,3

credit_played_goals
        ldx #0
played_scorer
        txa
        ldy home_team
        cpx #11
        bcc played_home
        sbc #11
        ldy away_team
played_home
        sta player_slot
        lda LEAGUE_MATCH_SCORERS,x
        jsr credit_player
        inx
        cpx #22
        bcc played_scorer
        rts

; For simulated fixtures, assign goals to the two forward slots.
credit_simulated
        sta player_slot
simulated_scorer
        lda player_slot
        beq simulated_done
        jsr roll_random
        and #1
        clc
        adc #9
        tax
        lda player_slot
        pha
        stx player_slot
        lda #1
        jsr credit_player
        pla
        sta player_slot
        dec player_slot
        bne simulated_scorer
simulated_done
        rts

; Add A goals to Y's player_slot. Preserve the caller's X and team Y.
credit_player
        pha
        txa
        pha
        tya
        asl
        asl
        asl
        asl
        ora player_slot
        tax
        pla
        sta temp
        pla
        clc
        adc player_goals_lo,x
        sta player_goals_lo,x
        bcc credit_done
        inc player_goals_hi,x
credit_done
        ldx temp
        rts

top_scorer
        lda #0
        sta scorer_hi
        sta scorer_lo
        ldx #0
scorer_scan
        lda player_goals_hi,x
        cmp scorer_hi
        bne scorer_order
        lda player_goals_lo,x
        cmp scorer_lo
        beq scorer_next
scorer_order
        bcc scorer_next
        lda player_goals_hi,x
        sta scorer_hi
        lda player_goals_lo,x
        sta scorer_lo
        stx scorer_index
scorer_next
        inx
        bpl scorer_scan
        lda scorer_hi
        ora scorer_lo
        beq scorer_done
        lda #19
        sta row
        ldx #3
        lda #<scorer_label
        ldy #>scorer_label
        jsr print_at
        lda scorer_index
        lsr
        lsr
        lsr
        lsr
        tay
        jsr roster_pointer
        lda scorer_index
        and #15
        tax
scorer_name
        jsr advance_name
        dex
        bpl scorer_name
        ldx #9
        jsr print_name
        ldx #34
        jsr position
        lda scorer_hi
        sta number_hi
        lda scorer_lo
        sta number_lo
        ldx #0
scorer_digit
        lda #0
        sta temp
scorer_subtract
        lda number_lo
        sec
        sbc decimal_lo,x
        tay
        lda number_hi
        sbc decimal_hi,x
        bcc scorer_output
        sta number_hi
        sty number_lo
        inc temp
        bne scorer_subtract
scorer_output
        txa
        tay
        lda temp
        jsr print_digit
        inx
        cpx #4
        bcc scorer_digit
scorer_done
        rts
decimal_lo dta <1000,<100,<10,<1
decimal_hi dta >1000,>100,>10,>1

add_result
        lda result_home,x
        sta compare_lo
        lda result_away,x
        sta compare_hi
        ldy fixture_home,x
        jsr add_team_result
        lda compare_lo
        pha
        lda compare_hi
        sta compare_lo
        pla
        sta compare_hi
        ldy fixture_away,x
add_team_result
        lda gf_lo,y
        clc
        adc compare_lo
        sta gf_lo,y
        lda gf_hi,y
        adc #0
        sta gf_hi,y
        lda gd_lo,y
        clc
        adc compare_lo
        sta gd_lo,y
        lda gd_hi,y
        adc #0
        sta gd_hi,y
        lda gd_lo,y
        sec
        sbc compare_hi
        sta gd_lo,y
        lda gd_hi,y
        sbc #0
        sta gd_hi,y
        lda compare_lo
        cmp compare_hi
        beq team_draw
        bcc team_loss
        lda wins,y
        clc
        adc #1
        sta wins,y
        lda #3
        bne add_points
team_loss
        lda losses,y
        clc
        adc #1
        sta losses,y
        rts
team_draw
        lda draws,y
        clc
        adc #1
        sta draws,y
        lda #1
add_points
        clc
        adc points,y
        sta points,y
        rts

sort_table
        ldx #7
rank_reset
        txa
        sta ranking,x
        dex
        bpl rank_reset
        lda #7
        sta rank_index
sort_pass
        ldx #0
sort_pair
        stx candidate
        ldy ranking,x
        lda ranking+1,x
        tax
        jsr compare_teams
sort_order
        bcs sort_next
        txa
        ldx candidate
        sta ranking,x
        tya
        sta ranking+1,x
sort_next
        ldx candidate
        inx
        cpx rank_index
        bcc sort_pair
        dec rank_index
        bne sort_pass
        rts

compare_teams
        lda points,y
        cmp points,x
        bne compared
        lda gd_hi,x
        eor #$80
        sta temp
        lda gd_hi,y
        eor #$80
        cmp temp
        bne compared
        lda gd_lo,y
        cmp gd_lo,x
        bne compared
        lda gf_hi,y
        cmp gf_hi,x
        bne compared
        lda gf_lo,y
        cmp gf_lo,x
compared
        rts

; Character output uses the original menu font and 40-column colour RAM.
clear_screen
        ldx #0
        lda #$fd
clear_chars
        sta text_screen,x
        sta text_screen+$100,x
        sta text_screen+$200,x
        sta text_screen+$300,x
        inx
        bne clear_chars
        lda #1
clear_colours
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $db00,x
        inx
        bne clear_colours
        rts
highlight
        lda #7
colour_row
        pha
        ldx #0
        jsr position
        lda dst+1
        clc
        adc #$60
        sta dst+1
        pla
        ldy #37
colour_cell
        sta (dst),y
        dey
        cpy #1
        bne colour_cell
        rts

position
        txa
        ldy row
        clc
        adc row_lo,y
        sta dst
        lda row_hi,y
        adc #>text_screen
        sta dst+1
        rts

print_at
        sta source
        sty source+1
        jsr position
        ldy #0
text_next
        lda (source),y
        beq print_done
        jsr screen_char
        sta (dst),y
        iny
        bne text_next
print_done
        rts

screen_char
        cmp #'A'
        bcc below_letter
        clc
        adc #$98
        rts
below_letter
        cmp #'0'
        bcc space_char
        cmp #('9'+1)
        bcs space_char
        clc
        adc #$c3
        rts
space_char
        lda #$fd
        rts

print_club
        jsr roster_pointer
print_name
        jsr position
        ldy #0
name_next
        lda (name_ptr),y
        jsr screen_char
        sta (dst),y
        iny
        cpy #24
        bcc name_next
        rts
roster_pointer
        lda roster_lo,y
        sta name_ptr
        lda roster_hi,y
        sta name_ptr+1
        rts
advance_name
        lda name_ptr
        clc
        adc #24
        sta name_ptr
        bcc advance_done
        inc name_ptr+1
advance_done
        rts

number_at
        pha
        jsr position
        pla
        ldx #0
        sec
number_tens
        cmp #10
        bcc number_units
        sbc #10
        inx
        bne number_tens
number_units
        pha
        txa
        ldy #0
        cpx #0
        bne number_nonzero
        lda #$fd
        sta (dst),y
        jmp number_last
number_nonzero
        jsr print_digit
number_last
        pla
        iny
print_digit
        clc
        adc #$f3
        sta (dst),y
        rts

row_lo
        :25 dta <(#*40)
row_hi
        :25 dta >(#*40)
fire_mask dta 16
finished_label dta c'FINAL TABLE',0
help_lo dta <help_new,<help_friendly,<help_continue,<help_options
help_hi dta >help_new,>help_friendly,>help_continue,>help_options
help_new dta c'START A NEW 14 ROUND SEASON',0
help_friendly dta c'SET UP TEAMS AND PLAY A FRIENDLY',0
help_continue dta c'RESUME YOUR SEASON',0
help_options dta c'SET PITCH AND MATCH DURATION',0
help_classic dta c'ORIGINAL GAME MODES AND SETTINGS',0
title dta c'RETRO FANS LEAGUE',0
new_label dta c'NEW LEAGUE',0
friendly_label dta c'FRIENDLY',0
continue_label dta c'CONTINUE LEAGUE',0
no_season dta c'NO ACTIVE SEASON',0
options_label dta c'MATCH OPTIONS',0
classic_label dta c'CLASSIC GAME',0
home_lo dta <new_label,<friendly_label,<continue_label,<options_label
home_hi dta >new_label,>friendly_label,>continue_label,>options_label
pick_help dta c'UP DOWN CHOOSE   FIRE OPEN',0
escape_help dta c'ESC BACK TO PARENT MENU',0
choose_club dta c'CHOOSE YOUR CLUB',0
choose_away dta c'CHOOSE THE AWAY CLUB',0
table_header dta c'CLUB                   W  D  L  PTS',0
champion_label dta c'CHAMPION',0
joint_label dta c'JOINT CHAMPIONS',0
scorer_label dta c'TOP',0
round_label dta c'ROUND',0
table_help dta c'W WINS  D DRAWS  L LOSSES  PTS POINTS',0
table_help2 dta c'FIRE OR ESC BACK TO LEAGUE MENU',0
starting_label dta c'SHIRT NUMBER   STARTING TEAM',0
reserve_label dta c'RESERVES   VIEW ONLY',0
squad_help dta c'LEFT RIGHT CLUB    FIRE BACK',0
fixtures_help dta c'LEFT RIGHT ROUND   FIRE BACK',0
return_help dta c'FIRE  RETURN TO MENU',0
result_help dta c'FIRE  BACK TO LEAGUE MENU',0
vertical_mask dta 3
pitch_label dta c'PITCH',0
length_label dta c'MATCH LENGTH',0
option_help dta c'UP DOWN PICK   LEFT RIGHT CHANGE',0
pitch0 dta c'RANDOM',0
pitch1 dta c'FROZEN',0
pitch2 dta c'MUDDY',0
pitch3 dta c'WET',0
pitch4 dta c'SOFT',0
pitch5 dta c'NORMAL',0
pitch6 dta c'DRY',0
pitch7 dta c'HARD',0
pitch_lo dta <pitch0,<pitch1,<pitch2,<pitch3,<pitch4,<pitch5,<pitch6,<pitch7
pitch_hi dta >pitch0,>pitch1,>pitch2,>pitch3,>pitch4,>pitch5,>pitch6,>pitch7
length0 dta c'3 MINUTES',0
length1 dta c'5 MINUTES',0
length2 dta c'7 MINUTES',0
length3 dta c'10 MINUTES',0
length_lo dta <length0,<length1,<length2,<length3
length_hi dta >length0,>length1,>length2,>length3
        icl '../gen/league-tables.asm'
        ert * > $d000
