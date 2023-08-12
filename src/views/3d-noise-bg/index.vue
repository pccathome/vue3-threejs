<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { useMediaQuery } from '@vueuse/core'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
// import { gsap } from 'gsap'
import VertexShader from './shader/vertext.glsl?raw'
import FragmentShader from './shader/fragment.glsl?raw'
import backBtn from '../../components/backBtn.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

// const goBack = $router.back()
const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()
scene.background = new THREE.Color('#000000')
scene.fog = new THREE.Fog(0x000000, 0.1, 1)

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

camera.position.set(0, 0, 10)
scene.add(camera)

const isMobile = useMediaQuery('(max-width: 768px)')

if (isMobile.value) {
    camera.position.set(0, 0, 11)
} else {
    camera.position.set(0, 0, 10)
}

const Light = new THREE.HemisphereLight(0xffffff, 0x000000, 1.0)
scene.add(Light)

// Geometry
const geo = new THREE.SphereGeometry(1, 3)
const mat = new THREE.ShaderMaterial({
    vertexShader: VertexShader,
    fragmentShader: FragmentShader,
    uniforms: {
        time: { value: 1.0 },
        pointscale: { value: 1.0 },
        decay: { value: 2.0 },
        complex: { value: 2.0 },
        waves: { value: 3.0 },
        eqcolor: { value: 3.0 },
        fragment: { value: false },
        dnoise: { value: 0.0 },
        qnoise: { value: 4.0 },
        r_color: { value: 0.0 },
        g_color: { value: 0.0 },
        b_color: { value: 0.0 }
    }
})

const mesh3D = new THREE.Mesh(geo, mat)
let mesh = new THREE.Object3D()
mesh.add(mesh3D)
mesh.scale.set(1.25, 1.25, 1.25)
scene.add(mesh)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const clock = new THREE.Clock()
    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = false
    controls.enabled = false
    controls.enableZoom = false

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        mesh.rotation.y += 0.001
        mat.uniforms.time.value = elapsedTime * 0.04
        mat.uniforms.pointscale.value = 1.0
        mat.uniforms.decay.value = 0.35
        // mat.uniforms.complex.value = 0.0
        mat.uniforms.waves.value = 10.5
        mat.uniforms.eqcolor.value = 11.0
        mat.uniforms.r_color.value = 6.0
        mat.uniforms.g_color.value = 0.0
        mat.uniforms.b_color.value = 0.15
        mat.uniforms.fragment.value = false
        controls.update()
        renderer.render(scene, camera)

        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(mesh)
    renderer.forceContextLoss()
    renderer.dispose()
    mat.dispose()
    geo.dispose()
    renderer.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    THREE.Cache.clear()
})
</script>

<template>
    <div class="relative h-screen w-full">
        <div class="outline-none w-full h-full absolute z-0" ref="webgl"></div>
        <div class="absolute w-full h-screen flex items-center justify-center z-4">
            <div class="text-center text-white font-Noto">
                <h1 class="text-3xl md:text-5xl font-semibold">pccathome.dev</h1>
                <p class="text-xs md:text-sm mt-5">- GLSL textureless classic 3D noise -</p>
            </div>
        </div>
        <backBtn />
    </div>
</template>
