//Shader "Unlit/Wireframe"
//{
//    Properties
//    {
//       [Header(Albedo)]
//        [MainColor] _BaseColor("Base Color", Color) = (1.0, 1.0, 1.0, 1.0)
//        [MainTexture] _BaseMap("Base Map", 2D) = "white" {}
//
//        [Header(NormalMap)]
//        [Toggle(_NORMALMAP)] _NORMALMAP("Normal Map使用有無", Int) = 0
//        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
//        [HideInInspector] _BumpScale("Bump Scale", Float) = 1.0
//
//        [Header(Occlution)]
//        [Toggle(_OCCLUSIONMAP)] _OCCLUSIONMAP("Occlusion Map使用有無", Int) = 0
//        [NoScaleOffset] _OcclusionMap("Occlusion Map", 2D) = "white" {}
//        [HideInInspector] _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
//
//        [Header(Metallic and Smoothness)]
//        _Smoothness("Smoothness(Map使用時はAlpha=1の箇所の値)", Range(0.0, 1.0)) = 0.0
//        [Toggle(_METALLICSPECGLOSSMAP)] _METALLICSPECGLOSSMAP("Metallic and Smoothness Map使用有無", Int) = 0
//        _Metallic("Metallic(Map不使用時のみ)", Range(0.0, 1.0)) = 0.0
//        [NoScaleOffset] _MetallicGlossMap("Metallic and Smoothnes Map", 2D) = "white" {}
//
//        [Header(Emission)]
//        [Toggle(_EMISSION)] _EMISSION("Emission使用有無", Int) = 0
//        [HDR] _EmissionColor("Emission Color", Color) = (0.0 ,0.0, 0.0)
//        [NoScaleOffset] _EmissionMap("Emission Map", 2D) = "white" {}
//
//        [Header(Wireframe)]
//        _WireframeWidth("ワイヤーフレーム幅", Range(1, 50)) = 1
//        _WireframeColor("ワイヤーフレーム色", Color) = (0.0, 0.0, 1.0, 1.0)
//        _WireframeEmissionColor("ワイヤーフレームのEmission Color", Color) = (0.0, 0.0, 0.0)
//        
//        [Space(10)]
//        [KeywordEnum(Off, Front, Back)] _Cull ("Cull", Int) = 2 
//}
//    SubShader
//    {
//        LOD 300
//        Cull [_Cull]
//        Blend SrcAlpha OneMinusSrcAlpha
//        Tags 
//        {
//            "Queue" = "Transparent" 
//            "RenderType" = "Transparent"
//            "RenderPipeline" = "UniversalPipeline"
//            "UniversalMaterialType" = "Lit"
//        }
//        
//        HLSLINCLUDE
//        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//        ENDHLSL
//
//        Pass
//        {
//            CGPROGRAM
//            #pragma vertex vert
//            #pragma fragment frag
//            // make fog work
//            #pragma multi_compile_fog
//
//            #include "UnityCG.cginc"
//
//            struct appdata
//            {
//                float4 vertex : POSITION;
//                float2 uv : TEXCOORD0;
//            };
//
//            struct v2f
//            {
//                float2 uv : TEXCOORD0;
//                UNITY_FOG_COORDS(1)
//                float4 vertex : SV_POSITION;
//            };
//
//            sampler2D _MainTex;
//            float4 _MainTex_ST;
//
//            v2f vert (appdata v)
//            {
//                v2f o;
//                o.vertex = UnityObjectToClipPos(v.vertex);
//                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//                UNITY_TRANSFER_FOG(o,o.vertex);
//                return o;
//            }
//
//            fixed4 frag (v2f i) : SV_Target
//            {
//                // sample the texture
//                fixed4 col = tex2D(_MainTex, i.uv);
//                // apply fog
//                UNITY_APPLY_FOG(i.fogCoord, col);
//                return col;
//            }
//            ENDCG
//        }
//    }
//}
