<script setup>
import { onMounted, onUnmounted, ref, reactive } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
// import { gsap } from 'gsap'
import VertexShader from './shaders/vertext.glsl?raw'
import FragmentShader from './shaders/fragment.glsl?raw'

// FPS stats
const stats = new Stats()
document.body.appendChild(stats.dom)

const webgl = ref(null)
const scene = new THREE.Scene()
const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()
camera.position.set(0, 0, 3)
scene.add(camera)

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

// Geometry
const geometry = new THREE.PlaneGeometry(1, 1)

// Material
const material = new THREE.ShaderMaterial({
    vertexShader: VertexShader,
    fragmentShader: FragmentShader,
    uniforms: {
        //     uTime: { value: 0 },
        //     uColor: { value: colors },
        // resolution: { value: new THREE.Vector2(sizes.width, sizes.height) }
    },
    side: THREE.DoubleSide,
    wireframe: false,
    transparent: false
})

const plane = new THREE.Mesh(geometry, material)
scene.add(plane)

const controls = new OrbitControls(camera, document.body)
controls.enableDamping = true
controls.enabled = true

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)

    const clock = new THREE.Clock()

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        // material.uniforms.uTime.value = elapsedTime * 0.02

        renderer.render(scene, camera)
        window.requestAnimationFrame(tick)

        stats.update()
    }

    tick()
})
</script>

<template>
    <div class="webgl outline-none" ref="webgl"></div>
</template>
