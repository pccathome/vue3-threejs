<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
import { gsap } from 'gsap'
import VertexShader from './shader/vertext.glsl?raw'
import FragmentShader from './shader/fragment.glsl?raw'
import backBtn from '../../components/backBtn.vue'
import footerInfo from '../../components/footerinfo.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

// const goBack = $router.back()
const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()
// scene.background = new THREE.Color('#f6f6f6')
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

camera.position.set(1.5, -1.5, 4.5)
scene.add(camera)

// Geometry
const sphereGeometry = new THREE.SphereGeometry(0.33, 32, 32)

const hdr = new RGBELoader().load('/texture/empty_warehouse_01_2k.hdr', (texture) => {
    hdr.mapping = THREE.EquirectangularReflectionMapping
})
const sphereMaterial = new THREE.MeshPhysicalMaterial({
    transmission: 1.35,
    envMap: hdr,
    envMapIntensity: 1.5,
    clearcoat: 0.3,
    clearcoatRoughness: 0.25,
    ior: 1.25,
    roughness: 0,
    metalness: 0,
    thickness: 2.6,
    side: THREE.DoubleSide
})
const sphereMesh = new THREE.Mesh(sphereGeometry, sphereMaterial)
scene.add(sphereMesh)

const geometry1 = new THREE.TorusGeometry(0.8, 0.15, 26, 150)
const geometry2 = new THREE.TorusGeometry(0.49, 0.15, 26, 150)

// Material
const material = new THREE.ShaderMaterial({
    vertexShader: VertexShader,
    fragmentShader: FragmentShader,
    uniforms: {
        cameraPosition: { value: camera.position },
        uTexture: { value: null },
        winResolution: {
            value: new THREE.Vector2(sizes.width, sizes.height).multiplyScalar(Math.min(window.devicePixelRatio, 2))
        },

        uIorY: { value: 1.16 },
        uIorC: { value: 1.22 },
        uIorP: { value: 1.22 },
        uIorR: { value: 1.15 },
        uIorG: { value: 1.08 },
        uIorB: { value: 1.22 },

        uChromaticAberration: { value: 0.45 },
        uSaturation: { value: 1.15 }, // 1.15
        uShininess: { value: 8.5 },
        uDiffuseness: { value: 0.05 },
        uFresnelPower: { value: 8.0 },
        uLight: { value: new THREE.Vector3(-2.0, 1.0, 1.0) }
    }
})
const mesh1 = new THREE.Mesh(geometry1, material)
const mesh2 = new THREE.Mesh(geometry2, material)

scene.add(mesh1, mesh2)

let tl = gsap.timeline({ repeat: -1 })
tl.to(mesh1.rotation, {
    duration: 3,
    x: Math.PI * 1
})
tl.to(mesh2.rotation, {
    duration: 2,
    y: Math.PI * 1
})

// const onMouseMove = (e) => {
//     const x = e.clientX
//     const y = e.clientY

//     gsap.to(mesh1.rotation, {
//         y: gsap.utils.mapRange(0, window.innerWidth, 0.5, -0.5, x),
//         x: gsap.utils.mapRange(0, window.innerHeight, 0.5, -0.5, y)
//     })
// }
// window.addEventListener('mousemove', onMouseMove, false)

// Render Target
const mainRenderTarget = new THREE.WebGLRenderTarget(
    sizes.height * Math.min(window.devicePixelRatio, 2),
    sizes.width * Math.min(window.devicePixelRatio, 2)
)

const backRenderTarget = new THREE.WebGLRenderTarget(
    sizes.height * Math.min(window.devicePixelRatio, 2),
    sizes.width * Math.min(window.devicePixelRatio, 2)
)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const clock = new THREE.Clock()
    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = true
    controls.enabled = true
    controls.maxAzimuthAngle = Math.PI / 2
    controls.minAzimuthAngle = -Math.PI / 2
    controls.enableZoom = false

    const tick = () => {
        // const elapsedTime = clock.getElapsedTime()

        controls.update()

        // ------------------------------
        mesh1.visible = false

        renderer.setRenderTarget(backRenderTarget)
        renderer.render(scene, camera)

        mesh1.material.uniforms.uTexture.value = backRenderTarget.texture
        mesh1.material.side = THREE.BackSide

        mesh1.visible = true

        renderer.setRenderTarget(mainRenderTarget)
        renderer.render(scene, camera)

        mesh1.material.uniforms.uTexture.value = mainRenderTarget.texture
        mesh1.material.side = THREE.FrontSide

        renderer.setRenderTarget(null)
        // ------------------------------------

        renderer.render(scene, camera)

        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    tl.kill()
    tl = null
    scene.remove(sphereMesh, mesh1, mesh2)
    renderer.forceContextLoss()
    renderer.dispose()
    sphereMaterial.dispose()
    sphereMaterial.dispose()
    geometry1.dispose()
    geometry2.dispose()
    material.dispose()
    renderer.dispose()
    backRenderTarget.dispose()
    mainRenderTarget.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    THREE.Cache.clear()
})
</script>

<template>
    <div class="relative">
        <div class="outline-none w-full h-full relative" ref="webgl"></div>
        <backBtn />
        <footerInfo>
            <a
                href="https://blog.maximeheckel.com/posts/refraction-dispersion-and-other-shader-light-effects/"
                target="_blank"
                class="underline-offset-2"
            >
                Refraction
            </a>
        </footerInfo>
    </div>
</template>