<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { useMediaQuery } from '@vueuse/core'
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
import footerInfo from '../../components/footerinfo.vue'

import matcap from '/texture/steel_matcap.jpg'

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

// const isMobile = useMediaQuery('(max-width: 768px)')

// if (isMobile.value) {
//     camera.position.set(0, 0, 11)
// } else {
//     camera.position.set(0, 0, 10)
// }

// ------------------------------------

// mouse move
const mouse = new THREE.Vector2()
function mouseMove(e) {
    mouse.x = (e.clientX / sizes.width) * 2 - 1
    mouse.y = -(e.clientY / sizes.height) * 2 + 1
}
document.addEventListener('mousemove', mouseMove)

function touchMove(e) {
    const touch = e.touches[0]
    mouse.x = (touch.clientX / sizes.width) * 2 - 1
    mouse.y = -(touch.clientY / sizes.height) * 2 + 1
}
document.addEventListener('touchmove', touchMove, { passive: false })

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
        material.uniforms.mouse.value = mouse

        controls.update()

        renderer.render(scene, camera)

        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(plane, camera)
    renderer.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    THREE.Cache.clear()
})
</script>

<template>
    <div class="relative outline-none h-screen w-full select-none">
        <div class="outline-none select-none w-full h-full absolute z-0" ref="webgl"></div>
        <backBtn />
        <footerInfo>
            <template v-slot:first></template>
            <template v-slot:second>
                <a
                    href="https://www.youtube.com/watch?v=q2WcGi3Cr9w&ab_channel=YuriArtiukh"
                    target="_blank"
                    class="underline-offset-2"
                    >Yuri Artiukh: Raymarching simple scene</a
                >
            </template>
        </footerInfo>
    </div>
</template>
