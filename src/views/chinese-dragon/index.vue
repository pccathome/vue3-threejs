<script setup>
import { onMounted, onBeforeUnmount, ref } from 'vue'
import { useMediaQuery } from '@vueuse/core'
import * as THREE from 'three'
import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js'
// import Stats from 'three/examples/jsm/libs/stats.module'
import { useSizes } from '../../threeBase/sizes'
import { useRenderer } from '../../threeBase/renderer'
import pageWrap from '../../components/pageWrap.vue'
import backBtn from '../../components/backBtn.vue'
import footerInfo from '../../components/footerinfo.vue'
import loadingIco from '../../components/loadingIco.vue'

import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader'
import env from '/texture/env.jpg'
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer'
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass'
import { UnrealBloomPass } from 'three/examples/jsm/postprocessing/UnrealBloomPass'
import { OutputPass } from 'three/examples/jsm/postprocessing/OutputPass'
import { gsap } from 'gsap'

// FPS
// const stats = new Stats()
// document.body.appendChild(stats.dom)

const webgl = ref(null)
const { sizes } = useSizes()
const { renderer } = useRenderer()
// const { camera } = usePerCamera()
const camera = new THREE.PerspectiveCamera(75, sizes.width / sizes.height, 0.1, 1000)
const scene = new THREE.Scene()
const clock = new THREE.Clock()

camera.position.set(0, 0, 1)
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

scene.background = new THREE.Color('#000000')
scene.fog = new THREE.Fog('#000000', 0.7, 1)

let composer, dragon

const params = {
    threshold: 0.1,
    strength: 0.6,
    radius: 0.8,
    exposure: 0
}
const loading = ref(true)
const loadingManager = new THREE.LoadingManager(
    () => {
        loading.value = false
    },
    (file, loaded, total) => {
        const progress = loaded / total
        console.log(`Loading audio: ${progress * 100}%`)
    }
)

function init() {
    renderer.toneMapping = THREE.ACESFilmicToneMapping
    renderer.toneMappingExposure = 0.1

    const pmremGenerator = new THREE.PMREMGenerator(renderer)
    pmremGenerator.compileEquirectangularShader()

    const envMap = new THREE.TextureLoader(loadingManager).load(env, (texture) => {
        const envMap = pmremGenerator.fromEquirectangular(texture).texture
        pmremGenerator.dispose()

        const loader = new GLTFLoader(loadingManager)
        loader.setPath('/models/')

        loader.load('dragon.glb', (gltf) => {
            scene.add(gltf.scene)
            dragon = gltf.scene.children[0]
            dragon.scale.set(1.4, 1.4, 1.4)
            dragon.rotation.x = 1.3
            dragon.position.y = 0.05
            dragon.position.z = -0.05

            let m = new THREE.MeshStandardMaterial({
                metalness: 1,
                roughness: 0.03
            })
            m.envMap = envMap

            // shader
            m.onBeforeCompile = (shader) => {
                shader.uniforms.uTime = { value: 0 }

                shader.fragmentShader =
                    `
                    uniform float uTime;
                    mat4 rotationMatrix(vec3 axis, float angle) {
                        axis = normalize(axis);
                        float s = sin(angle);
                        float c = cos(angle);
                        float oc = 1.0 - c;

                        return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                                    oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                                    oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                                    0.0,                                0.0,                                0.0,                                1.0);
                    }

                    vec3 rotate(vec3 v, vec3 axis, float angle) {
                        mat4 m = rotationMatrix(axis, angle);
                        return (m * vec4(v, 1.0)).xyz;
                    }
                ` + shader.fragmentShader

                shader.fragmentShader = shader.fragmentShader.replace(
                    `#include <envmap_physical_pars_fragment>`,
                    `
                    #ifdef USE_ENVMAP
                        vec3 getIBLIrradiance( const in vec3 normal ) {
                            #ifdef ENVMAP_TYPE_CUBE_UV
                                vec3 worldNormal = inverseTransformDirection( normal, viewMatrix );
                                vec4 envMapColor = textureCubeUV( envMap, worldNormal, 1.0 );
                                return PI * envMapColor.rgb * envMapIntensity;
                            #else
                                return vec3( 0.0 );
                            #endif
                        }

                        vec3 getIBLRadiance( const in vec3 viewDir, const in vec3 normal, const in float roughness ) {
                            #ifdef ENVMAP_TYPE_CUBE_UV
                                vec3 reflectVec = reflect( - viewDir, normal );

                                // Mixing the reflection with the normal is more accurate and keeps rough objects from gathering light from behind their tangent plane.
                                reflectVec = normalize( mix( reflectVec, normal, roughness * roughness) );
                                reflectVec = inverseTransformDirection( reflectVec, viewMatrix );

                                // change time
                                reflectVec = rotate(reflectVec, vec3(1.0, 0.0, 0.0), uTime);
                                vec4 envMapColor = textureCubeUV( envMap, reflectVec, roughness );
                                return envMapColor.rgb * envMapIntensity;
                            #else
                                return vec3( 0.0 );
                            #endif
                        }
                    #endif
                    `
                )

                m.userData.shader = shader
            }

            dragon.material = m

            // bloom pass
            const bloom = () => {
                const renderScene = new RenderPass(scene, camera)

                const bloomPass = new UnrealBloomPass(new THREE.Vector2(sizes.width, sizes.height), 1.5, 0.4, 0.85)
                bloomPass.threshold = params.threshold
                bloomPass.strength = params.strength
                bloomPass.radius = params.radius

                const outputPass = new OutputPass()

                composer = new EffectComposer(renderer)
                composer.addPass(renderScene)
                composer.addPass(bloomPass)
                composer.addPass(outputPass)
            }
            bloom()

            // gsap
            const tl = gsap.timeline()
            tl.pause()
            tl.to(dragon.rotation, { duration: 8, x: 0.25, ease: 'sine.inOut' }).to(dragon.position, {
                duration: 1,
                z: 0.3,
                y: 0.1,
                ease: 'power4.in'
            })

            const tick = () => {
                const elapsedTime = clock.getElapsedTime()
                if (m.userData.shader !== undefined) {
                    dragon.material.userData.shader.uniforms.uTime.value = elapsedTime * 0.3
                }

                // renderer.render(scene, camera)
                composer.render(scene, camera)

                window.requestAnimationFrame(tick)
            }
            tick()

            window.addEventListener('mousedown', () => {
                tl.play()
            })

            window.addEventListener('mouseup', () => {
                tl.reverse()
            })

            window.addEventListener('touchstart', () => {
                tl.play()
            })

            window.addEventListener('touchend', () => {
                tl.reverse()
            })
        })
    })

    // mouse follower
    gsap.set('.flair', { xPercent: -50, yPercent: -50 })

    let xTo = gsap.quickTo('.flair', 'x', { duration: 1, ease: 'power3' }),
        yTo = gsap.quickTo('.flair', 'y', { duration: 1, ease: 'power3' })

    window.addEventListener('mousemove', (e) => {
        xTo(e.clientX)
        yTo(e.clientY)
    })

    const holdBtn = document.querySelector('.flair')
    document.addEventListener('mousedown', () => {
        holdBtn.classList.add('active_btn')
    })
    document.addEventListener('mouseup', () => {
        holdBtn.classList.remove('active_btn')
    })
}

onMounted(() => {
    webgl.value.appendChild(renderer.domElement)

    const controls = new OrbitControls(camera, webgl.value)
    controls.enableDamping = false
    controls.enabled = false
    controls.enableZoom = false
    // controls.maxAzimuthAngle = Math.PI / 6
    // controls.minAzimuthAngle = -Math.PI / 6
    // controls.minPolarAngle = Math.PI / 2
    // controls.maxPolarAngle = Math.PI / 2
    controls.update()

    init()
})

onBeforeUnmount(() => {
    if (init.envMap) {
        // 遍歷模型的每個部分並釋放資源
        gltf.scene.traverse((object) => {
            if (!object.isMesh) return

            object.geometry.dispose() // 釋放幾何體

            if (object.material.isMaterial) {
                cleanMaterial(object.material) // 清理材質
            } else {
                // 對於多材質的情況
                for (const material of object.material) {
                    cleanMaterial(material)
                }
            }
        })
    }

    function cleanMaterial(material) {
        material.dispose() // 釋放材質本身

        // 釋放材質中的紋理
        for (const key of Object.keys(material)) {
            const value = material[key]
            if (value && typeof value === 'object' && 'minFilter' in value) {
                value.dispose()
            }
        }
    }

    // window.removeEventListener('resize', myEventHandler)
    window.removeEventListener('mousedown', () => {
        tl.play()
    })

    window.removeEventListener('mouseup', () => {
        tl.reverse()
    })

    window.removeEventListener('touchstart', () => {
        tl.play()
    })

    window.removeEventListener('touchend', () => {
        tl.reverse()
    })

    window.removeEventListener('mousemove', (e) => {
        xTo(e.clientX)
        yTo(e.clientY)
    })

    document.removeEventListener('mousedown', () => {
        holdBtn.classList.add('active_btn')
    })
    document.removeEventListener('mouseup', () => {
        holdBtn.classList.remove('active_btn')
    })

    scene.remove(init.envMa) // 移除場景中的物體
    renderer.forceContextLoss() // 釋放WebGL上下文
    renderer.dispose() // 清理渲染器
    dragon.material.dispose() // 清理材質
    // geo.dispose() // 清理幾何體
    renderer.domElement = null // 移除參考
    renderer.clear() // 清理渲染器相關緩存
    scene.clear() // 清理場景
    camera.clear() // 如果有這個方法，清理相機
    THREE.Cache.clear() // 清理Three.js的緩存
})
</script>

<template>
    <pageWrap>
        <div class="block md:hidden select-none">
            <div class="fixed z-40 flex justify-center items-center w-full h-[300px]">
                <p class="text-white opacity-50 text-center text-[9px] leading-3">TOUCH & HOLD</p>
            </div>
        </div>
        <div v-if="loading" class="select-none z-10 h-screen inset-0 flex items-center justify-center">
            <loadingIco />
        </div>
        <div class="hidden md:block select-none">
            <div class="flair z-40 btn">
                <p class="text-white text-center text-[9px] leading-3">
                    CLICK<br />
                    & <br />HOLD
                </p>
            </div>
        </div>

        <div class="outline-none w-full h-full z-0 select-none" ref="webgl"></div>

        <backBtn />
        <footerInfo>
            <template v-slot:first> 3D Model by </template>
            <template v-slot:second>
                <a
                    href="https://sketchfab.com/3d-models/skatin-jade-dragon-75c8914b383749bcb259054ad668be2a"
                    target="_blank"
                    class="underline-offset-2"
                    >Ian Wilmoth SKATIN' jade dragon
                </a>
            </template>
        </footerInfo>
    </pageWrap>
</template>
