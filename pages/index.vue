<template lang="pug">
.splatoon2_weapon_quiz.spla_basic_font.is-unselectable
  .bg_window
  template(v-if="scene === 'sm_standby' || scene === 'sm_life_zero' || scene === 'sm_all_clear'")
    .field.title.has-text-centered.has-text-white
      div スプラトゥーン2
      div ブキめいクイズ

  template(v-if="scene === 'sm_standby'")
    .field.has-text-centered
      a.button.is-rounded.start_button(@click.prevent="start_handle") スタート

  template(v-if="scene === 'sm_running'")
    .basic_bar.player_life_bar.active(:style="{width: `${player_life_bar_rate * 100}%`}")

    .image_box
      img.sub_image(:src="require(`@/assets/splatoon2_weapon_list/${current_data.master.key}.png`)")
      transition(name="effect" appear)
        img.main_image(:src="require(`@/assets/splatoon2_weapon_list/${current_data.master.key}.png`)" :key="current_data.master.key")

    .basic_bar.time_limit_bar(:style="{visibility: bar_visibility, width: `${time_limit_bar_rate * 100}%`}" :class="{active: count_down >= 1}")
    .box
      ul
        template(v-if="scene2 === 'sm2_running'")
          li.selection.hoverable.sm2_running(v-for="e in current_data.choice_list" :key="e.key" @click.prevent="answerd_data_set(e)")
            template(v-if="NODE_ENV !== 'production' && current_data.master === e && !demo")
              | ◎
            span.spla_weapon_font {{hyphen_replace(e.name)}}
        template(v-else)
          li.selection.sm2_answer_open(v-for="e in current_data.choice_list" :key="e.key" :class="{o_item: current_data.master === e, x_item: current_data.master !== e, selected: e === answerd_data}")
            template(v-if="current_data.master === e")
              span.item_mark.has-text-danger ◎
            template(v-if="e === answerd_data && current_data.master !== e")
              span.item_mark.has-text-info ×
            span.spla_weapon_font {{hyphen_replace(e.name)}}

  template(v-if="scene === 'sm_life_zero' || scene === 'sm_all_clear'")
    .field.has-text-centered.has-text-white
      a.button.is-rounded.start_button(@click.prevent="start_handle") スタート

    .box.has-text-centered
      | せいかい {{o_count}}
      br
      | せいかいりつ {{answer_parcentage}}
      br
      | タイム {{time_format(total_counter / accuracy)}}
      br
      a.button.is-info.is-rounded.tweet_button(:href="twitter_url" target="_blank") ツイート

  template(v-if="NODE_ENV !== 'production' && !demo")
    .has-text-white
      ul
        li scene: {{scene}}
        li scene2: {{scene2}}
        li total_counter: {{total_counter / accuracy}}
        li quiz_list.length: {{quiz_list ? quiz_list.length : ""}}
        li o_count: {{o_count}} {{answer_parcentage}}
        li x_count: {{x_count}}
        li quiz_life_max_seconds: {{quiz_life_max_seconds}}
        li player_life_bar_rate: {{player_life_bar_rate}}

  template(v-if="scene === 'sm_standby' || scene === 'sm_life_zero' || scene === 'sm_all_clear'")
    a.credit.has-text-white.has-text-centered.is-size-7(@click.prevent="credit_modal_p = true") クレジット

  b-modal(:active.sync="credit_modal_p")
    header.modal-card-head
      p.modal-card-title
        | クレジット
    section.modal-card-body.is-size-7
      table.table.is-fullwidth
        tbody
          tr
            th フォント
            td
              a(href="https://aramugi.com/?page_id=807" target="_blank") イカモドキ (あらむぎ)
              br
              a(href="http://fizzystack.web.fc2.com/paintball-ja.html" target="_blank") Project Paintball (JapanYoshi)
              br
              a(href="https://googlefonts.github.io/japanese/" target="_blank") M PLUS Rounded 1c
          tr
            th おとそざい
            td
              a(href="https://otologic.jp" target="_blank") OtoLogic
          tr
            th がぞう
            td
              a(href="https://twitter.com/splatoonjp" target="_blank") スプラトゥーンこうしきツイッター
          tr
            th プログラム
            td
              a(href="https://twitter.com/splawarabimochi" target="_blank") @splawarabimochi
    template(v-if="true")
      footer.modal-card-foot
        .has-text-right
          button.button.is-primary.spla_basic_font(@click.prevent="credit_modal_p = false") とじる

  link(href="https://fonts.googleapis.com/earlyaccess/nicomoji.css" rel="stylesheet")
</template>

<script>
import { Howl, Howler } from 'howler'
import dayjs from "dayjs"
import _ from 'lodash'
import pkg from '~/package'

import splatoon2_weapon_list from "@/assets/splatoon2_weapon_list.js"

import o_mp3 from "@/assets/oto_logic/Quiz-Correct_Answer02-1.mp3"
import x_mp3 from "@/assets/oto_logic/Quiz-Wrong_Buzzer02-1.mp3"
import start_mp3 from "@/assets/oto_logic/Quiz-Question03-1.mp3"
import all_clear_mp3 from "@/assets/oto_logic/Quiz-Results02-1.mp3"

import game_over_mp3 from "@/assets/oto_logic/Onmtp-Ding05-1.mp3"

import bgm_mp3 from "@/assets/oto_logic/Loop02.mp3"
// import bgm_mp3 from "@/assets/oto_logic/Loop03.mp3"
// import bgm_mp3 from "@/assets/oto_logic/dotabatare-su.mp3"

export default {
  name: "splatoon2_weapon_quiz",

  head() {
    return {
      title: "ブキクイズ",
      link: [
        { hid: "apple-touch-icon", rel: "apple-touch-icon", href: require("@/assets/splatoon2_weapon_quiz.png"), },
        { hid: "favicon",          rel: "icon",             href: require("@/assets/splatoon2_weapon_quiz.png"), },
      ],

      meta: [
        { name: "twitter:card",       content: "summary",                                                                                      },
        { name: "twitter:site",       content: "@splawarabimochi",                                                                             },
        { name: "twitter:creator",    content: "@splawarabimochi",                                                                             },
        { property: "og:url",         content: "http://tk2-221-20341.vs.sakura.ne.jp/sp2quiz/",                                                },
        { property: "og:title",       content: "スプラトゥーン2ブキめいクイズ",                                                                },
        { property: "og:description", content: pkg.description,                                                                                },
        { property: "og:image",       content: "http://tk2-221-20341.vs.sakura.ne.jp" + require("@/assets/splatoon2_weapon_quiz_144x144.png"), },
      ],
    }
  },

  data() {
    return {
      NODE_ENV: process.env.NODE_ENV,

      splatoon2_weapon_list,

      demo: false,

      quiz_max: null,
      select_element_max: parseInt(this.$route.query.select_element_max || 3),

      answerd_data: null,

      current_index: null,
      o_count: null,
      x_count: null,
      total_counter: null,

      player_life_max: 100,    // 元の体力
      o_life: 20,              // 正解したときの加算値
      x_life: -5,              // 間違えたときの加算値
      player_life: null,
      player_life_add: -5,     // 1秒間に減らす値

      quiz_life: null,
      quiz_life_max_seconds: 5, // 1問の時間
      accuracy: 10,             // setTimeout の精度

      quiz_list: null,

      // count_down_bar_class: null,
      scene: "sm_standby",
      scene2: null,
      credit_modal_p: false,
      sound_list: [],

      tap_p: false,
      timer: null,
      last_touch: 0,
      interval_id: null,
    }
  },

  created() {
    // console.debug(this.$meta())

    // this.bg_window_create()

    this.user_scalable_none()

    this.quiz_max = this.$route.query.quiz_max
    if (this.NODE_ENV === "production") {
      this.quiz_max = this.quiz_max || this.splatoon2_weapon_list.length
    } else {
      this.quiz_max = this.quiz_max || 3

      if (this.demo) {
        this.player_life_max = 10000000
        this.quiz_life_max_seconds = 10000
      }

      // this.quiz_max = 3
      // this.quiz_max = this.splatoon2_weapon_list.length
      // this.quiz_life_max_seconds = 10000
      // this.player_life_max = 10000000
    }
  },

  mounted() {
    this.preload_images()
    this.interval_id = setInterval(this.interval_handle, 1000 / this.accuracy)
    //- this.start_handle()
  },

  beforeDestroy() {
    // this.bg_window_destroy()

    if (this.interval_id) {
      clearInterval(this.interval_id)
      this.interval_id = null
    }
  },

  methods: {
    preload_images() {
      this.splatoon2_weapon_list.forEach(e => {
        const preload_link = document.createElement("link")
        preload_link.href = require(`@/assets/splatoon2_weapon_list/${e.key}.png`)
        preload_link.rel = "preload"
        preload_link.as = "image"
        this.$el.appendChild(preload_link) // this.$el は document.querySelector(".splatoon2_weapon_quiz") のこと
      })
    },

    hyphen_replace(str) {
      return str
      // return str.replace(/-/g, "ー")
    },

    interval_handle() {
      if (this.scene === "sm_running") {
        if (this.scene2 === "sm2_running") {
        }
        this.total_counter += 1
        this.count_down += 1
        if (this.player_life > 0) {
          this.player_life += this.player_life_add / this.accuracy
          this.player_life_zero_check()
        }
        if (this.scene === "sm_running") {
          if (this.scene2 === "sm2_running") {
            if (this.quiz_life > 0) {
              this.quiz_life -= 1
              if (this.quiz_life <= 0) {
                this.count_add("x_count")
              }
            }
          }
        }
      }
    },

    start_handle() {
      this.scene = "sm_running"
      this.scene2 = "sm2_running"

      this.quiz_list = this.quiz_list_create()

      this.player_life = this.player_life_max
      this.current_index = 0
      this.o_count = 0
      this.x_count = 0
      this.total_counter = 0
      // this.count_down_bar_class = "anime_on"

      // this.sound_stop()
      this.sound_stop()
      this.sound_play({src: bgm_mp3, autoplay: true, volume: 0.5, loop: true})
      this.sound_play({src: start_mp3, autoplay: true, volume: 1.0})

      this.next_quiz_setup()
    },

    next_quiz_setup() {
      this.quiz_life = this.quiz_life_max_seconds * this.accuracy
      this.scene2 = "sm2_running"
      this.count_down = 0

      if (this.$refs.count_down_bar) {
        const parent = this.$refs.count_down_bar.parentElement
        parent.removeChild(this.$refs.count_down_bar)
        parent.appendChild(this.$refs.count_down_bar)
      }
    },

    count_add(v) {
      // const e = document.querySelector("body")
      // e.scrollTop = 0

      if (v === "o_count") {
        this.sound_play({src: o_mp3, autoplay: true, volume: 1.0})
        this.player_life += this.o_life
      } else {
        this.sound_play({src: x_mp3, autoplay: true, volume: 1.0})
        this.player_life += this.x_life
      }
      this.player_life = _.clamp(this.player_life, 0, this.player_life_max)
      this.player_life_zero_check()

      this.$data[v] = this.$data[v] + 1

      this.scene2 = "sm2_answer_open"

      setTimeout(() => {
        this.current_index += 1

        if (!this.current_data) {
          this.scene = "sm_all_clear"
          this.sound_stop()
          this.sound_play({src: all_clear_mp3, autoplay: true, volume: 1.0})
        }

        if (this.scene === "sm_running") {
          // this.$nextTick(() => {
          //   this.answerd_data = null
          //   document.activeElement.blur()
          //   if (this.scene === "sm_running") {
          //     this.next_quiz_setup()
          //   }
          // })

          this.answerd_data = null
          //   document.activeElement.blur()
          // if (this.scene === "sm_running") {
          this.next_quiz_setup()
          // }
          //   }
        }

      }, 1000 * 0.8)

    },

    player_life_zero_check() {
      if (this.player_life <= 0) {
        this.player_life = 0
        this.scene = "sm_life_zero"
        this.sound_stop()
        this.sound_play({src: game_over_mp3, autoplay: true, volume: 1.0})
      }
    },

    answerd_data_set(v) {
      if (this.scene2 === "sm2_running") {
        this.answerd_data = v
        if (this.current_data.master === v) {
          this.count_add("o_count")
        } else {
          this.count_add("x_count")
        }
      }
    },

    quiz_list_create() {
      let items = this.splatoon2_weapon_list

      if (this.demo) {
      } else {
        items = _.shuffle(items)
      }

      items = _.take(items, this.quiz_max)

      let rest = null

      const quiz_list = []
      items.forEach(item => {
        const collection = this.splatoon2_weapon_list.filter(e => e !== item)
        const list = collection.filter(e => e.sub_group === item.sub_group)
        let list2 = _.shuffle(list, this.select_element_max - 1)

        rest = (this.select_element_max - 1) - list2.length
        if (rest >= 1) {
          const list = collection.filter(e => e.group === item.group && !list2.includes(e))
          const list3 = _.take(_.shuffle(list), rest)
          list2 = [...list2, ...list3]
        }

        rest = (this.select_element_max - 1) - list2.length
        if (rest >= 1) {
          const list = collection.filter(e => !list2.includes(e))
          const list3 = _.take(_.shuffle(list), rest)
          list2 = [...list2, ...list3]
        }

        list2 = [...list2, ...[item]]

        list2 = _.sortBy(list2, e => e.name)

        quiz_list.push({master: item, choice_list: list2})
      })
      return quiz_list
    },

    sound_play(params) {
      this.sound_list.push(new Howl(params))
    },

    sound_stop() {
      this.sound_list.forEach(e => e.stop())
      this.sound_list = []
    },

    time_format(seconds) {
      return dayjs().startOf("year").set("seconds", seconds).format("m:ss")
    },

    // iOS10のSafariでuser-scalable=no が効かなくズームがされる問題への対策
    // https://qiita.com/peutes/items/d74e5758a36478fbc039
    user_scalable_none() {
      // スクロール禁止 (スマホ用)
      // https://qiita.com/shge/items/d2ae44621ce2eec183e6
      // document.addEventListener("touchmove", e => e.preventDefault(), {passive: false})

      // // ダブルタップ禁止 (スマホ用)
      // // https://qiita.com/peutes/items/d74e5758a36478fbc039#%E3%83%80%E3%83%96%E3%83%AB%E3%82%BF%E3%83%83%E3%83%97%E3%82%92%E9%98%B2%E3%81%90
      // document.addEventListener('touchend', e => {
      //   const now = window.performance.now()
      //   if (now - this.last_touch <= 500) {
      //     e.preventDefault()
      //   }
      //   this.last_touch = now
      // }, {passive: false})

      // 複数指で拡大縮小が出来てしまうのを防ぐ
      // https://qiita.com/peutes/items/d74e5758a36478fbc039#%E8%A4%87%E6%95%B0%E6%8C%87%E3%81%A7%E6%8B%A1%E5%A4%A7%E7%B8%AE%E5%B0%8F%E3%81%8C%E5%87%BA%E6%9D%A5%E3%81%A6%E3%81%97%E3%81%BE%E3%81%86%E3%81%AE%E3%82%92%E9%98%B2%E3%81%90
      // document.addEventListener('touchstart', e => {
      //   if (e.touches.length > 1) {
      //     e.preventDefault()
      //   }
      // }, {passive: false})
    },

    // bg_window_create() {
    //   const app = document.querySelector("#app")
    //   if (app) {
    //     const elem = document.createElement("div")
    //     elem.classList.add("bg_window")
    //     app.appendChild(elem)
    //   }
    // },

    // bg_window_destroy() {
    //   const elem = document.querySelector(".bg_window")
    //   if (elem) {
    //     elem.parentNode.removeChild(elem)
    //   }
    // },
  },

  computed: {
    bar_visibility() {
      if (this.time_limit_bar_rate > 0) {
        return "visible"
      } else {
        return "hidden"
      }
      // if (this.scene === "sm_running") {
      //   if (this.scene2 === "sm2_running") {
      //     return "visible"
      //   } else {
      //     return "hidden"
      //   }
      // }
    },

    time_limit_bar_rate() {
      return this.quiz_life / (this.quiz_life_max_seconds * this.accuracy) - 0.02
    },

    player_life_bar_rate() {
      return this.player_life / this.player_life_max
    },

    current_data() {
      return this.quiz_list[this.current_index]
    },

    last_data_p() {
      return this.current_index === (this.quiz_list.length - 1)
    },

    progress_value() {
      return this.player_life / this.player_life_max
    },

    answer_parcentage() {
      const all = this.o_count + this.x_count
      if (all >= 1) {
        return Math.floor(this.o_count / all * 100) + "%"
      } else {
        return "0%"
      }
    },

    twitter_url() {
      return `https://twitter.com/intent/tweet?text=${encodeURIComponent(this.tweet_body)}`
    },

    tweet_body() {
      return `#${this.current_title}
正解数: ${this.o_count}
正解率: ${this.answer_parcentage}
所要時間: ${this.time_format(this.total_counter / this.accuracy)}

${window.location.href}`
    },
  },
}
</script>

<style lang="sass">
@import "../assets/scss/variables"
@import "../assets/scss/splatoon_preset"

@import url("https://fonts.googleapis.com/css?family=M+PLUS+Rounded+1c:900")

@font-face
  font-family: "ProjectPaintballFontFace"
  src: url(../assets/project_paintball/project_paintball_beta_4_by_japanyoshi-d93slk4.otf)

@font-face
  font-family: "IkamodokiFontFace"
  src: url(../assets/ikamodoki/ikamodoki1_0.ttf)

.spla_basic_font
  font-family: "IkamodokiFontFace", "ProjectPaintballFontFace", "M PLUS Rounded 1c", sans-serif

// IkamodokiFontFace だとハイフンがイカになるため普通に表示される ProjectPaintballFontFace を優先する
// そしてなぜか上寄りなので下方向に微調整
.spla_weapon_font
  font-family: "ProjectPaintballFontFace", "IkamodokiFontFace", "M PLUS Rounded 1c", sans-serif
  position: relative
  top: 2px

$transition_x: 90vw             // スライド量

html
  overflow: hidden

  // 切り替わり時のちらつき軽減のため
  background: $sp_color_red_light

  .splatoon2_weapon_quiz
    // コンテンツのスクロールを禁止するため
    position: fixed
    top: 0
    left: 0
    right: 0
    bottom: 0

    padding: 0.5em

    .bg_window
      border: 1px dotted $primary
      background-color: $sp_color_red_dark
      background-image: repeating-linear-gradient(45deg, $sp_color_red_light, $sp_color_red_light 24px, transparent 0, transparent 48px)
      height: 2000vh            // 200vh 以上にする。200% 表記だとiPhoneでメニューから呼び出したとき縦幅が 200vh にならないので注意

      position: fixed           // absolute だとモバイルでスクロールしてしまう
      top: 0
      left: 0
      right: 0
      bottom: 0
      animation: scroll1 120s linear infinite
      z-index: -1

      @keyframes scroll1
        0%
          transform: translate(0, -50%)
        100%
          transform: translate(0, 0)

    .title
      margin-top: 1em
      color: hsla(0, 0%, 100%, 0.2) ! important
      font-size: 2.5em
      -webkit-text-stroke: 1px hsla(0, 50%, 100%, 1.0)

      @media screen and (min-width: $desktop)
        font-size: 6em

    .image_box
      position: relative
      // border: 1px dotted $primary

      // スライドする画像と同じサイズのエリアを確保するため
      .sub_image
        display: block        // inline 要素のままだと隙間ができるため
        visibility: hidden
        max-height: 40vh

      .main_image
        position: absolute
        top: 0
        left: 0
        right: 0
        bottom: 0
        margin: auto
        // border: 1px dotted $info
        height: 100%
        filter: drop-shadow(0px 0px 4px black)
        border-radius: 10px

      .effect-enter-active, .effect-leave-active
        transition: all 0.5s ease
      .effect-enter
        transform: translateX($transition_x)
      .effect-leave-to
        transform: translateX(-$transition_x)
      .effect-enter, .effect-leave-to
        opacity: 0

    .start_button
      margin-top: 2.5em
      margin-bottom: 2.5em

    progress, meter
      margin: 5px 0
      width: 100%
      border-radius: 4px

    .selection
      white-space: nowrap
      color: inherit
      width: 100%
      font-size: 120%
      line-height: 220%
      padding-left: 1em
      &.hoverable
        &:hover
          cursor: pointer
          border-radius: 1em
          background: hsla(331, 100%, 0%, 0.1)
      &.selected
        border-radius: 1em
        background: hsla(331, 100%, 0%, 0.2)
      &.sm2_answer_open
        transition: all 0.15s ease
      &.o_item
        padding-left: 0.25em
        font-size: 180%
      &.x_item
        // font-size: 100%
        opacity: 0.5

      .item_mark
        margin-right: 2px

    // @keyframes bar_anime1
    //   0%
    //     width: 100%
    //   100%
    //     width: 0%

    .basic_bar
      border: 1px solid white
      background: hsla(0, 50%, 100%, 0.3)
      border-radius: 4px
      margin-left: auto
      margin-right: auto

      &.player_life_bar
        margin-bottom: 5px
        height: 12px

      &.time_limit_bar
        margin-top: 6px
        margin-bottom: 5px
        height: 6px

      &.active
        transition: all 0.1s 0s linear

    // .box
    //   text-align: left

    .modal-card-foot
      justify-content: flex-end

    .tweet_button
      margin-top: 1em

    .credit
      position: fixed
      left: 0%
      right: 0%
      bottom: 0%
      height: 3.2%
      margin: auto

// モバイルのとき選択した部分が次の問題になっても残ってしまう対策
@media screen and (max-width: $desktop)
  .splatoon2_weapon_quiz
    .selection
      &.hoverable
        &:hover
          background: none
</style>
