<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
// import { useMediaQuery } from '@vueuse/core'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { useOrtCamera } from '../../threeBase/ort-camera'
// import { gsap } from 'gsap'
import VertexShader from './shader/vertext.glsl?raw'
import FragmentShader from './shader/fragment.glsl?raw'
import backBtn from '../../components/backBtn.vue'
import pageWrap from '../../components/pagewrap.vue'
import footerInfo from '../../components/footerinfo.vue'
import loadingIco from '../../components/loadingIco.vue'

import matcap from '/texture/black_cap2.png'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = useOrtCamera()

const webgl = ref(null)

const clock = new THREE.Clock()
const scene = new THREE.Scene()
scene.background = new THREE.Color('#000000')

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

camera.position.set(0, 0, 1)
scene.add(camera)

// audio
const isPlaying = ref(false)
const audio = ref(null)
const loading = ref(true)

const loadingManager = new THREE.LoadingManager(
    () => {
        loading.value = false
        isPlaying.value = false
    },
    (file, loaded, total) => {
        const progress = loaded / total
        console.log(`Loading audio: ${progress * 100}%`)
    }
)

const file = '/audio/knekksans.mp3'
const fftSize = 256
const listener = new THREE.AudioListener()
audio.value = new THREE.Audio(listener)
const audioLoader = new THREE.AudioLoader(loadingManager)

audioLoader.load(file, function (buffer) {
    audio.value.setBuffer(buffer)
})

const togglePlay = () => {
    if (isPlaying.value) {
        pauseAudio()
    } else {
        playAudio()
    }
}

const playAudio = () => {
    listener.context
        .resume()
        .then(() => {
            audio.value.play()
            isPlaying.value = true
        })
        .catch((error) => {
            console.error('Failed to resume audio context:', error)
        })
}

const pauseAudio = () => {
    audio.value.pause()
    isPlaying.value = false
}

const analyser = new THREE.AudioAnalyser(audio.value, fftSize)

let imageAspect = 1
let a1, a2
if (sizes.height / sizes.width > imageAspect) {
    a1 = (sizes.width / sizes.height) * imageAspect
    a2 = 1
} else {
    a1 = 1
    a2 = (sizes.height / sizes.width) * imageAspect
}

// Object
const geometry = new THREE.PlaneGeometry(1, 1, 1, 1)
const material = new THREE.ShaderMaterial({
    vertexShader: VertexShader,
    fragmentShader: FragmentShader,
    uniforms: {
        time: { value: 0 },
        progress: { value: 0 },
        uFrequency: { value: 0.0 },
        mouse: { value: new THREE.Vector2(0, 0) },
        matcap: { value: new THREE.TextureLoader().load(matcap) },
        resolution: { value: new THREE.Vector4(sizes.width, sizes.height, a1, a2) }
    },
    wireframe: false
})
const plane = new THREE.Mesh(geometry, material)
scene.add(plane)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = false
    controls.enabled = false
    controls.enableZoom = false

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        material.uniforms.time.value = elapsedTime
        material.uniforms.uFrequency.value = analyser.getAverageFrequency()

        controls.update()

        renderer.render(scene, camera)

        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(plane, camera) // 移除場景中的物體
    renderer.forceContextLoss() // 釋放WebGL上下文
    renderer.dispose() // 清理渲染器
    material.dispose() // 清理材質
    geometry.dispose() // 清理幾何體
    renderer.domElement = null // 移除參考
    renderer.clear() // 清理渲染器相關緩存
    scene.clear() // 清理場景
    camera.clear() // 如果有這個方法，清理相機
    THREE.Cache.clear() // 清理Three.js的緩存

    if (audio.value) {
        audio.value.stop() // 停止音頻播放
        audio.value.disconnect() // 斷開音頻連接
        // audio.value = null // 釋放對音頻對象的引用
        audio.value.buffer = null
        listener.remove(audio.value)
    }
})
</script>

<template>
    <!-- <div class="relative h-screen w-full overflow-hidden"> -->
    <pageWrap>
        <div class="outline-none w-full h-full absolute z-0" ref="webgl"></div>
        <div class="h-screen inset-0 flex items-center justify-center mt-28 sm:mt-0">
            <div v-if="loading" class="z-10">
                <loadingIco />
            </div>
            <button
                v-else
                @click="togglePlay"
                class="border border-zinc-700 rounded-2xl w-16 h-6 sm:w-20 sm:h-8 bg-black hover:bg-gray-900 text-gray-200 opacity-90 font-extralight text-xs"
            >
                {{ isPlaying ? 'PAUSE' : 'PLAY' }}
            </button>
        </div>
        <backBtn />
        <footerInfo>
            <template v-slot:first></template>
            <template v-slot:second>
                <a
                    href="https://www.youtube.com/watch?v=3OKPA8ne57A&ab_channel=RayFerrofluid"
                    target="_blank"
                    class="underline-offset-2"
                    >Ferrofluid Speaker Audio Visualizer.
                </a>
            </template>
        </footerInfo>
    </pageWrap>
    <!-- </div> -->
</template>
