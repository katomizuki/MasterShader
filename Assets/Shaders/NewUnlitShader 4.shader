Shader "Unlit/NewUnlitShader 4"
{
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
// GPUインスタンシングを有効にするためにmulti_compile_instancingを定義
            // これをつけるとEnableGpuInstancingに自動でチェックがつく。手動でつけることも可能。
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
//UNITY_VERTEX_INPUT_INSTANCE_ID変数を定義 
            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                // ここで実際にinstanceIDをセットアップする
                UNITY_SETUP_INSTANCE_ID(v);
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return float4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}
