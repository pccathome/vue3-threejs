<script setup>
import dateInfo from '../components/dateInfo.vue'
import dataItems from '../data/items.json'
</script>
<template>
    <div class="w-full h-full">
        <div class="md:w-[767px] mx-auto px-4 pb-24">
            <div class="mx-auto my-14 px-3 flex items-center justify-between">
                <div>
                    <span class="text-base mr-4"> &#128406;</span>
                    <span class="font-neue_hass_roman text-[9px] antialiased uppercase text-white opacity-50">
                        Live &nbsp; long &nbsp; and&nbsp; prosper
                    </span>
                </div>

                <ul class="flex items-center gap-12">
                    <li>
                        <a href="https://twitter.com/pccathome" target="_blank" rel="noreferrer noopener">
                            <img class="h-4 opacity-50 hover:opacity-100" src="../assets/images/twitter.svg" />
                        </a>
                    </li>
                    <li>
                        <a href="https://github.com/pccathome/vue3-threejs" target="_blank" rel="noreferrer noopener">
                            <img class="h-4 opacity-50 hover:opacity-100" src="../assets/images/github.svg" />
                        </a>
                    </li>
                    <li>
                        <a href="mailto:pccathome@gmail.com">
                            <img class="h-4 opacity-50 hover:opacity-100" src="../assets/images/mail.svg" />
                        </a>
                    </li>
                </ul>
            </div>

            <section class="grid grid-rows-1 md:grid-cols-2 gap-6 mx-auto">
                <div v-for="(item, index) in dataItems" :key="index" class="relative">
                    <router-link :to="`${item.link}`">
                        <video
                            playsinline
                            loop
                            autoplay
                            muted
                            class="shape-inside hover:border-gradient background-animate"
                        >
                            <source :src="item.mp4" type="video/mp4" />
                        </video>
                        <dateInfo>{{ item.date }}</dateInfo>
                    </router-link>
                </div>
            </section>
        </div>
    </div>
</template>
