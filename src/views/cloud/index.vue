<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
// import { useMediaQuery } from '@vueuse/core'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { ImprovedNoise } from 'three/examples/jsm/math/ImprovedNoise.js'
import { Water } from 'three/examples/jsm/objects/Water.js'
import { Sky } from 'three/examples/jsm/objects/Sky.js'
import { LineGeometry } from 'three/examples/jsm/lines/LineGeometry.js'
import { LineMaterial } from 'three/examples/jsm/lines/LineMaterial.js'
import { Line2 } from 'three/examples/jsm/lines/Line2.js'

import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer.js'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass.js'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass.js'

import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'

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
renderer.autoClear = false
renderer.toneMapping = THREE.ACESFilmicToneMapping
renderer.toneMappingExposure = 0.49

const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()

window.addEventListener('resize', () => {
    // Update sizes
    sizes.width = window.innerWidth
    sizes.height = window.innerHeight

    // Update camera
    camera.aspect = sizes.width / sizes.height
    camera.updateProjectionMatrix()

    // Update renderer
    renderer.setSize(sizes.width, sizes.height)
    bloomComposer.setSize(sizes.width, sizes.height)
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2))
})

camera.position.set(0, 8, 350)
scene.add(camera)

// Bloom
const renderScene = new RenderPass(scene, camera)
const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 0.85)
bloomPass.renderToScreen = true
bloomPass.threshold = 0.0
bloomPass.strength = 3.5
bloomPass.radius = 0.5
const bloomComposer = new EffectComposer(renderer)
bloomComposer.setSize(sizes.width, sizes.height)
bloomComposer.addPass(renderScene)
bloomComposer.addPass(bloomPass)

// Water
const waterGeometry = new THREE.PlaneGeometry(10000, 10000)

const water = new Water(waterGeometry, {
    textureWidth: 512,
    textureHeight: 512,
    waterNormals: new THREE.TextureLoader().load('/texture/waternormals.jpg', function (texture) {
        texture.wrapS = texture.wrapT = THREE.RepeatWrapping
    }),
    sunDirection: new THREE.Vector3(),
    sunColor: '#D1C1B4',
    waterColor: '#445463',
    distortionScale: 6.7
})

water.rotation.x = -Math.PI / 2
water.layers.set(0)
scene.add(water)

// Skybox
const sky = new Sky()
sky.scale.setScalar(10000)
sky.layers.set(0)
scene.add(sky)

const skyUniforms = sky.material.uniforms

skyUniforms['turbidity'].value = 6
skyUniforms['rayleigh'].value = 0.45
skyUniforms['mieCoefficient'].value = 0.01
skyUniforms['mieDirectionalG'].value = 0.8

const parameters = {
    elevation: 1.2,
    azimuth: 55
}
let sun = new THREE.Vector3()
const pmremGenerator = new THREE.PMREMGenerator(renderer)
let renderTarget

const updateSun = () => {
    const phi = THREE.MathUtils.degToRad(90 - parameters.elevation)
    const theta = THREE.MathUtils.degToRad(parameters.azimuth)

    sun.setFromSphericalCoords(1, phi, theta)

    sky.material.uniforms['sunPosition'].value.copy(sun)
    water.material.uniforms['sunDirection'].value.copy(sun).normalize()

    if (renderTarget !== undefined) renderTarget.dispose()

    renderTarget = pmremGenerator.fromScene(sky)

    scene.environment = renderTarget.texture
}

updateSun()

// Cloud Texture
const size = 230
const data = new Uint8Array(size * size * size)

let i = 0
const scale = 0.055
const perlin = new ImprovedNoise()
const vector = new THREE.Vector3()

for (let z = 0; z < size; z++) {
    for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
            const d =
                1.0 -
                vector
                    .set(x, y, z)
                    .subScalar(size / 2)
                    .divideScalar(size)
                    .length()
            data[i] = (128 + 128 * perlin.noise((x * scale) / 1.5, (y * scale) / 1.5, (z * scale) / 1.5)) * d * d
            i++
        }
    }
}

const texture = new THREE.Data3DTexture(data, size, size, size)
texture.format = THREE.RedFormat
texture.minFilter = THREE.LinearFilter
texture.magFilter = THREE.LinearFilter
texture.unpackAlignment = 1
texture.needsUpdate = true

// Cloud Geometry
const cloudGeo = new THREE.BoxGeometry(1, 1, 1)
const cloudMat = new THREE.RawShaderMaterial({
    vertexShader: VertexShader,
    fragmentShader: FragmentShader,
    glslVersion: THREE.GLSL3,
    uniforms: {
        time: { value: 1.0 },
        base: { value: new THREE.Color('#7E6A6B') },
        map: { value: texture },
        cameraPos: { value: new THREE.Vector3() },
        threshold: { value: 0.22 },
        opacity: { value: 0.25 },
        range: { value: 0.06 },
        steps: { value: 50 },
        frame: { value: 0 }
    },
    side: THREE.BackSide,
    transparent: true
})

const cloudMesh = new THREE.Mesh(cloudGeo, cloudMat)
cloudMesh.position.set(0, 19, 210)
cloudMesh.scale.set(35, 43, 35)
cloudMesh.layers.set(1)
scene.add(cloudMesh)

// Line
const lineGeo = new LineGeometry()
lineGeo.setPositions([-16, -1, 270, 190, 190, 270])

const lineMat = new LineMaterial({
    color: '#FA2626',
    linewidth: 0.002
})

const line = new Line2(lineGeo, lineMat)
line.layers.set(0)
scene.add(line)

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)
    const clock = new THREE.Clock()
    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = false
    controls.enabled = false
    controls.enableZoom = false

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()
        // mat.uniforms.time.value = elapsedTime * 0.04
        cloudMesh.material.uniforms.cameraPos.value.copy(camera.position)
        cloudMesh.rotation.y = -performance.now() / 6500
        cloudMesh.material.uniforms.frame.value++
        water.material.uniforms.time.value = elapsedTime * 0.2

        controls.update()

        renderer.clear()
        camera.layers.set(0)
        bloomComposer.render()

        renderer.clearDepth()
        camera.layers.set(1)
        renderer.render(scene, camera)

        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(line, cloudMesh, sky, water)
    renderer.dispose()
    waterGeometry.dispose()
    lineMat.dispose()
    lineGeo.dispose()
    cloudGeo.dispose()
    cloudMat.dispose()
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
        <backBtn />
        <footerInfo>
            <a
                href="https://www.jennsingergallery.com/shop/ecstasy-still-by-david-stenbeck"
                target="_blank"
                class="underline-offset-2"
                >Ecstasy Still by David Stenbeck</a
            >
        </footerInfo>
    </div>
</template>
