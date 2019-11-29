using System.Collections;
using System.Collections.Generic;
using UnityEngine;



[RequireComponent(typeof(Camera))]
public class PostEffector : MonoBehaviour {

    public Material effect;
    private Camera cam;

    public void Start()
    {

    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        
        if (effect == null)
            Graphics.Blit(source, destination);
        else
            Graphics.Blit(source, destination, effect);
    }
}
