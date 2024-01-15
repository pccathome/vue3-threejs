<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { useMediaQuery } from '@vueuse/core'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
import { RGBELoader } from 'three/examples/jsm/loaders/RGBELoader.js'
import { DragControls } from 'three/examples/jsm/controls/DragControls'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import { usePerCamera } from '../../threeBase/per-camera'
import * as CANNON from 'cannon-es'
import { gsap } from 'gsap'
import backBtn from '../../components/backBtn.vue'
import pageWrap from '../../components/pagewrap.vue'
import loadingIco from '../../components/loadingIco.vue'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const { sizes } = useSizes()
const { renderer } = useRenderer()
const { camera } = usePerCamera()

const webgl = ref(null)

const scene = new THREE.Scene()
scene.background = new THREE.Color('#000000')

const world = new CANNON.World()
world.gravity.set(0, -0.001, 0)
world.broadphase = new CANNON.NaiveBroadphase()

const light = new THREE.AmbientLight(0x404040, 9.5) // soft white light
light.position.set(1, 0, 3)
scene.add(light)

const directionalLight = new THREE.DirectionalLight(0xffffff, 1.5)
directionalLight.castShadow = true
directionalLight.shadow.camera.near = 10
directionalLight.shadow.camera.far = 50
directionalLight.shadow.camera.top = 10
directionalLight.shadow.camera.right = 10
directionalLight.shadow.camera.bottom = -10
directionalLight.shadow.camera.left = -10
directionalLight.shadow.radius = 10
directionalLight.position.z = -8
directionalLight.position.y = 22
scene.add(directionalLight)

const directionalLightCameraHelper = new THREE.CameraHelper(directionalLight.shadow.camera)
directionalLightCameraHelper.visible = false
scene.add(directionalLightCameraHelper)

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

const distancePC = -80
const distanceMobile = -74

const isMobile = useMediaQuery('(max-width: 768px)')

if (isMobile.value) {
    camera.position.set(0, 100 + distanceMobile, 0)
} else {
    camera.position.set(0, 100 + distancePC, 0)
}

scene.add(camera)

//--------------------------------------------------------------
// overlay for loading...
const overlayGeometry = new THREE.PlaneGeometry(2, 2, 1, 1)
const overlayMaterial = new THREE.ShaderMaterial({
    transparent: true,
    uniforms: { uAlpha: { value: 1 } },
    vertexShader: `
        void main() {
            gl_Position = vec4(position, 1.0);
        }
    `,
    fragmentShader: `
        uniform float uAlpha;

        void main() {
            gl_FragColor = vec4(0.0, 0.0, 0.0, uAlpha);
        }
    `
})
const overlay = new THREE.Mesh(overlayGeometry, overlayMaterial)
scene.add(overlay)

const loading = ref(true)
const loadingManager = new THREE.LoadingManager(
    () => {
        gsap.to(overlayMaterial.uniforms.uAlpha, { duration: 3, value: 0 })
        loading.value = false
    },
    (url, loaded, total) => {
        const progress = loaded / total
        console.log(`Loading: ${progress * 100}%`)
    }
)

const textureLoader = new THREE.TextureLoader(loadingManager)
const tX = textureLoader.load('/texture/unsplash.jpg')
const planeMat = new THREE.MeshStandardMaterial({
    map: tX
})

const planeGeometry = new THREE.PlaneGeometry(35, 25)
const planeMesh = new THREE.Mesh(planeGeometry, planeMat)
planeMesh.rotateX(-Math.PI / 2)
planeMesh.receiveShadow = true
scene.add(planeMesh)

const planeShape = new CANNON.Plane()
const planeBody = new CANNON.Body({ mass: 0 })
planeBody.addShape(planeShape)
planeBody.quaternion.setFromAxisAngle(new CANNON.Vec3(1, 0, 0), -Math.PI / 2)
world.addBody(planeBody)

const sphereMeshes = []
const sphereBodies = []
const sphereGeometry = new THREE.SphereGeometry(1, 32, 32)

const hdr = new RGBELoader(loadingManager).load('/texture/empty_warehouse_01_2k.hdr', (texture) => {
    hdr.mapping = THREE.EquirectangularReflectionMapping
})
const material = new THREE.MeshPhysicalMaterial({
    envMap: hdr,
    reflectivity: 0.9,
    transmission: 0.9,
    envMapIntensity: 0.35,
    ior: 1.4,
    roughness: 0,
    metalness: 0,
    thickness: 2.2
})

const sphereMesh = new THREE.Mesh(sphereGeometry, material)

let i = 0
for (let x = -4; x <= 4; x += 2) {
    for (let z = -4; z <= 4; z += 2) {
        const sphereMeshClone = sphereMesh.clone()
        sphereMeshClone.position.x = x
        sphereMeshClone.position.y = 2
        sphereMeshClone.position.z = z
        sphereMeshClone.castShadow = true
        sphereMeshClone.userData.i = i
        scene.add(sphereMeshClone)
        sphereMeshes.push(sphereMeshClone)

        const sphereBody = new CANNON.Body({ mass: 1 })
        sphereBody.addShape(new CANNON.Sphere(1))
        sphereBody.position.x = sphereMeshClone.position.x
        sphereBody.position.y = sphereMeshClone.position.y
        sphereBody.position.z = sphereMeshClone.position.z
        world.addBody(sphereBody)
        sphereBodies.push(sphereBody)

        const localPivotSphere = new CANNON.Vec3(0, 0, 1)
        const localPivotPlane = new CANNON.Vec3(x, z, 0)
        const constraint = new CANNON.PointToPointConstraint(sphereBody, localPivotSphere, planeBody, localPivotPlane)
        world.addConstraint(constraint)

        i++
    }
}

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)

    const controls = new OrbitControls(camera, webgl.value)
    controls.enabled = false
    controls.enableZoom = false

    let draggingId = -1
    const dragControls = new DragControls(sphereMeshes, camera, renderer.domElement)
    dragControls.addEventListener('dragstart', function (event) {
        draggingId = event.object.userData.i
        // console.log(draggingId)
    })
    dragControls.addEventListener('dragend', function (event) {
        draggingId = -1
    })
    dragControls.addEventListener('drag', function (event) {
        event.object.position.y = 1
    })

    const clock = new THREE.Clock()
    // let delta

    const tick = () => {
        const elapsedTime = clock.getElapsedTime()

        const delta = Math.min(elapsedTime, 0.1)
        world.step(delta)

        sphereMeshes.forEach((m, i) => {
            if (i === draggingId) {
                sphereBodies[i].position.x = m.position.x
                sphereBodies[i].position.y = m.position.y
                sphereBodies[i].position.z = m.position.z
                sphereBodies[i].quaternion.x = m.quaternion.x
                sphereBodies[i].quaternion.y = m.quaternion.y
                sphereBodies[i].quaternion.z = m.quaternion.z
                sphereBodies[i].quaternion.w = m.quaternion.w
                sphereBodies[i].velocity.set(0, 0, 0)
                sphereBodies[i].angularVelocity.set(0, 0, 0)
            } else {
                m.position.set(sphereBodies[i].position.x, sphereBodies[i].position.y, sphereBodies[i].position.z)
                m.quaternion.set(
                    sphereBodies[i].quaternion.x,
                    sphereBodies[i].quaternion.y,
                    sphereBodies[i].quaternion.z,
                    sphereBodies[i].quaternion.w
                )
            }
        })

        controls.update()
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFSoftShadowMap
        renderer.render(scene, camera)
        window.requestAnimationFrame(tick)

        // stats.update()
    }
    tick()
})

onBeforeUnmount(() => {
    scene.remove(planeMesh, light, directionalLight, directionalLightCameraHelper)

    world.removeBody(sphereBodies, planeBody)
    sphereMeshes.length = 0
    sphereBodies.length = 0
    renderer.forceContextLoss()
    renderer.dispose()
    tX.dispose()
    planeMat.dispose()
    hdr.dispose()
    material.dispose()
    renderer.domElement = null
    renderer.clear()
    scene.clear()
    camera.clear()
    THREE.Cache.clear()
})
</script>

<template>
    <pageWrap>
        <div v-if="loading" class="z-10 h-screen inset-0 flex items-center justify-center">
            <loadingIco />
        </div>
        <backBtn />
        <div id="webgl" class="webgl outline-none w-full h-screen z-0" ref="webgl"></div>
    </pageWrap>
</template>
